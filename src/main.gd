extends Node2D


@onready var furni_option_button: OptionButton = %FurniOptionButton


@export var furni_types_path: StringName = "res://data/furni_types"
@export var curr_room: Room


var furni_types: Array[FurniType] = []
var floor_tile_map: TileMapLayer

var hovered_tile: Vector2i = Vector2i(-1, -1)  # Tile under the mouse
var ghost_furni: FurniSprite = null            # Furniture preview


func _ready() -> void:
	assert(curr_room != null, "Must have starting room.")

	load_furni_types()
	populate_option_button()

	floor_tile_map = curr_room.floor_tile_map
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
	if ghost_furni:
		ghost_furni.queue_free()

	var selected_furni: FurniType = furni_types[index]
	ghost_furni = selected_furni.create()
	ghost_furni.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent preview

	add_child(ghost_furni)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		place_furniture_at_mouse()


func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	hovered_tile = world_to_tile(mouse_pos)

	# Move the ghost furniture preview
	if ghost_furni and hovered_tile != Vector2i(-1, -1):
		ghost_furni.position = tile_to_world(hovered_tile)

	# Redraw the grid overlay
	queue_redraw()


func _draw() -> void:
	if hovered_tile != Vector2i(-1, -1):
		var world_pos: Vector2 = tile_to_world(hovered_tile)
		
		# Get the actual tile size from the tilemap's tileset
		var tile_size: Vector2 = floor_tile_map.get_parent().tile_set.tile_size
		var tile_half_width: float = tile_size.x / 2
		var tile_half_height: float = tile_size.y / 2
		
		# Convert from global to local coordinates for the Main node
		var local_pos: Vector2 = to_local(world_pos)
		
		# Define the four corners of an isometric tile (diamond shape)
		var p1: Vector2 = local_pos + Vector2(0, -tile_half_height)  # Top
		var p2: Vector2 = local_pos + Vector2(tile_half_width, 0)    # Right
		var p3: Vector2 = local_pos + Vector2(0, tile_half_height)   # Bottom
		var p4: Vector2 = local_pos + Vector2(-tile_half_width, 0)   # Left
		
		# Draw the isometric diamond
		draw_polyline([p1, p2, p3, p4, p1], Color(1, 1, 0, 1), 2)
		
		# Optional: Draw a dot at the center for reference
		draw_circle(local_pos, 2, Color(1, 0, 0, 1))


func place_furniture_at_mouse() -> void:
	if hovered_tile != Vector2i(-1, -1):
		var selected_index: int = furni_option_button.get_selected_id()

		if selected_index != -1:
			var furni_type: FurniType = furni_types[selected_index]
			var furni_sprite: FurniSprite = furni_type.create()
			
			# Use the tile_to_world function for consistent placement
			furni_sprite.position = tile_to_world(hovered_tile)
			
			# Only apply y-offset if needed for visual alignment of the furniture sprite
			# This should be a property of the furniture type rather than a fixed value
			# For now, you can adjust this value or comment it out to test alignment
			# furni_sprite.position.y -= 8
			
			add_child(furni_sprite)


## Convert world position to tile coordinates using the TileMap's local_to_map()
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return floor_tile_map.local_to_map(floor_tile_map.to_local(world_pos))


## Convert tile coordinates to world position using the TileMap's map_to_local()
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))
