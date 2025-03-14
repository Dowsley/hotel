extends Node2D


@onready var furni_option_button: OptionButton = %FurniOptionButton


@export var furni_types_path: StringName = "res://data/furni_types"
@export var curr_room: Room


var furni_types: Array[FurniType] = []
var floor_tile_map: TileMapLayer

var hovered_tile: Vector2i = Vector2i(-1, -1)  # Tile under the mouse
var ghost_furni: FurniSprite = null            # Furniture preview

# Grid visualization
var grid_marker: Node2D = null


func _ready() -> void:
	assert(curr_room != null, "Must have starting room.")

	load_furni_types()
	populate_option_button()

	floor_tile_map = curr_room.floor_tile_map
	
	# Create a grid marker to show the selected tile
	create_grid_marker()
	
	furni_option_button.selected = 0
	_on_furni_option_button_item_selected(0)


func load_furni_types() -> void:
	var dir: DirAccess = DirAccess.open(furni_types_path)
	assert(dir != null, "Failed to open directory: " + furni_types_path)

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource: FurniType = load(furni_types_path + "/" + file_name)
			if resource != null:
				furni_types.append(resource)
		file_name = dir.get_next()


func populate_option_button() -> void:
	furni_option_button.clear()

	for i: int in range(furni_types.size()):
		furni_option_button.add_item(furni_types[i].name, i)


## Remove old ghost furniture if it exists
func _on_furni_option_button_item_selected(index: int) -> void:
	pass
	#if ghost_furni:
		#ghost_furni.queue_free()
#
	#var selected_furni: FurniType = furni_types[index]
	#ghost_furni = selected_furni.create()
	#ghost_furni.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent preview
#
	#add_child(ghost_furni)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		place_furniture_at_mouse()


func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var new_hovered_tile = world_to_tile(mouse_pos)
	
	# Only update if the hovered tile has changed
	if new_hovered_tile != hovered_tile:
		hovered_tile = new_hovered_tile
		
		# Update the grid marker position
		if grid_marker and hovered_tile != Vector2i(-1, -1):
			var tile_center_world = floor_tile_map.to_global(floor_tile_map.map_to_local(hovered_tile))
			grid_marker.position = tile_center_world
			grid_marker.visible = true
		elif grid_marker:
			grid_marker.visible = false
		
		# Move the ghost furniture preview
		if ghost_furni and hovered_tile != Vector2i(-1, -1):
			ghost_furni.position = tile_to_world(hovered_tile)


func _draw() -> void:
	pass


func place_furniture_at_mouse() -> void:
	if hovered_tile != Vector2i(-1, -1):
		var selected_index: int = furni_option_button.get_selected_id()

		if selected_index != -1:
			var furni_type: FurniType = furni_types[selected_index]
			var furni_sprite: FurniSprite = furni_type.create()
			
			# Get the exact world position for the center of the tile
			var tile_center_world = floor_tile_map.to_global(floor_tile_map.map_to_local(hovered_tile))
			furni_sprite.position = tile_center_world
			
			# Furniture sprites often need a height adjustment for proper isometric appearance
			# Uncomment and adjust if necessary for your specific sprites
			# furni_sprite.position.y -= furni_type.visual_offset.y
			
			add_child(furni_sprite)


## Convert world position to tile coordinates using the TileMap's local_to_map()
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return floor_tile_map.local_to_map(floor_tile_map.to_local(world_pos))


## Convert tile coordinates to world position using the TileMap's map_to_local()
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))


# Creates a dedicated node for showing the grid highlight
func create_grid_marker() -> void:
	grid_marker = Node2D.new()
	grid_marker.name = "GridMarker"
	add_child(grid_marker)
	
	# Create a new script instance for the grid marker
	var script = GDScript.new()
	script.source_code = """
extends Node2D

var tile_size: Vector2 = Vector2(32, 16)  # Default tile size, will be updated

func _ready() -> void:
	# Make sure this node is always drawn on top
	z_index = 10

func _process(_delta: float) -> void:
	# Ensure it's always redrawn
	queue_redraw()

func _draw() -> void:
	# Define the diamond points based on tile size
	var points = []
	points.append(Vector2(0, -tile_size.y/2))          # Top
	points.append(Vector2(tile_size.x/2, 0))           # Right
	points.append(Vector2(0, tile_size.y/2))           # Bottom
	points.append(Vector2(-tile_size.x/2, 0))          # Left
	points.append(Vector2(0, -tile_size.y/2))          # Back to top (close the shape)
	
	# Draw the diamond outline with a nice yellow color
	draw_polyline(points, Color(1, 1, 0, 1), 2.0)
	
	# Optional: Draw the center point for reference
	draw_circle(Vector2.ZERO, 3, Color(1, 0, 0, 1))
	
	# Optional: Fill the diamond with a semi-transparent color
	draw_colored_polygon(points, Color(1, 1, 0, 0.2))
"""
	script.reload()
	
	grid_marker.set_script(script)
	
	# Set initial tile size
	if floor_tile_map and floor_tile_map.tile_set:
		grid_marker.set("tile_size", floor_tile_map.tile_set.tile_size)
