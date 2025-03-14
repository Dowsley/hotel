extends Node2D


@onready var furni_option_button: OptionButton = %FurniOptionButton
@onready var camera: Camera2D = $Camera2D


@export var furni_types_path: StringName = "res://data/furni_types"
@export var curr_room: Room
@export var min_zoom: float = 1.0  # Maximum zoom in
@export var max_zoom: float = 4.0  # Maximum zoom out
@export var zoom_step: float = 0.1  # How much to zoom per scroll


var furni_types: Array[FurniType] = []
var floor_tile_map: TileMapLayer = null

var hovered_tile: Vector2i = Vector2i(-1, -1)
## For furniture preview
var ghost_furni: FurniSprite = null

## Grid visualization
var grid_marker: Node2D = null

## Container for all furniture with Y-sorting
var furniture_container: Node2D = null

## Dictionary to track furniture by position
## Key: Vector2i (tile position), Value: FurniSprite
var furni_by_position: Dictionary = {}


func _ready() -> void:
	assert(curr_room != null, "Must have starting room.")

	load_furni_types()
	populate_option_button()

	floor_tile_map = curr_room.floor_tile_map
	
	create_grid_marker()
	create_furniture_container()
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


func _on_furni_option_button_item_selected(index: int) -> void:
	if ghost_furni:
		ghost_furni.queue_free()

	var selected_furni: FurniType = furni_types[index]
	ghost_furni = selected_furni.create()
	ghost_furni.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent preview

	# Don't add ghost furniture to the Y-sorted container
	# It should always be on top of other furniture
	ghost_furni.z_index = 100 # Ensure it's always on top
	add_child(ghost_furni)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_furniture_at_mouse()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			remove_furniture_at_mouse()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		rotate_ghost_furniture()
		
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(-zoom_step)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(zoom_step)


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered_tile := world_to_tile(mouse_pos)
	
	# Only update if the hovered tile has changed
	if new_hovered_tile != hovered_tile:
		hovered_tile = new_hovered_tile
		
		# Check if the hovered tile is valid (is a floor and has no furniture)
		var is_valid_tile := is_valid_tile_position(hovered_tile)
		
		# Update the grid marker position - only show on valid floor tiles
		if grid_marker:
			if is_valid_tile:
				var tile_center_world := floor_tile_map.to_global(floor_tile_map.map_to_local(hovered_tile))
				grid_marker.position = tile_center_world
				grid_marker.visible = true
			else:
				grid_marker.visible = false
		
		# Update ghost furniture visibility and position based on validity
		if ghost_furni:
			if is_valid_tile and hovered_tile != Vector2i(-1, -1):
				ghost_furni.position = tile_to_world(hovered_tile)
				ghost_furni.position += ghost_furni.type.visual_offset
				ghost_furni.visible = true
				ghost_furni.modulate = Color(1, 1, 1, 0.5)  # Normal semi-transparent
			else:
				ghost_furni.visible = false


func zoom_camera(zoom_amount: float) -> void:
	if camera:
		var current_zoom := camera.zoom.x
		var new_zoom: float = clamp(current_zoom - zoom_amount, min_zoom, max_zoom)
		camera.zoom = Vector2(new_zoom, new_zoom)


func is_valid_tile_position(tile_pos: Vector2i) -> bool:
	if floor_tile_map.get_cell_source_id(tile_pos) < 0:
		return false
	
	if furni_by_position.has(tile_pos):
		return false
	
	return true


func place_furniture_at_mouse() -> void:
	if hovered_tile != Vector2i(-1, -1) and is_valid_tile_position(hovered_tile):
		var selected_index: int = furni_option_button.get_selected_id()

		if selected_index != -1:
			var furni_type: FurniType = furni_types[selected_index]
			var furni_sprite: FurniSprite = furni_type.create()
			
			# Get the exact world position for the center of the tile
			var tile_center_world := floor_tile_map.to_global(floor_tile_map.map_to_local(hovered_tile))
			furni_sprite.position = tile_center_world
			
			# Apply vertical offset from the furniture type
			furni_sprite.position += furni_type.visual_offset
			
			# Apply the same rotation as the ghost furniture if it exists
			if ghost_furni:
				furni_sprite.current_rotation_frame = ghost_furni.current_rotation_frame
			
			# Add to the Y-sorted container instead of directly to the scene
			furniture_container.add_child(furni_sprite)
			
			# Track the furniture by position
			furni_by_position[hovered_tile] = furni_sprite


## Convert world position to tile coordinates using the TileMap's local_to_map()
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return floor_tile_map.local_to_map(floor_tile_map.to_local(world_pos))


## Convert tile coordinates to world position using the TileMap's map_to_local()
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))


## Creates a dedicated node for showing the grid highlight
func create_grid_marker() -> void:
	grid_marker = GridMarker.new()
	add_child(grid_marker)
	
	if floor_tile_map and floor_tile_map.tile_set:
		grid_marker.set("tile_size", floor_tile_map.tile_set.tile_size)


## Creates a Y-sorted container for all furniture
func create_furniture_container() -> void:
	furniture_container = Node2D.new()
	furniture_container.name = "FurnitureContainer"
	furniture_container.y_sort_enabled = true  # Enable Y-sorting
	add_child(furniture_container)


## Rotates the ghost furniture to the next rotation frame
func rotate_ghost_furniture() -> void:
	if ghost_furni:
		ghost_furni.rotate_to_next_frame()


## Removes furniture at the current mouse position if it exists
func remove_furniture_at_mouse() -> void:
	if hovered_tile != Vector2i(-1, -1):
		# Check if there's furniture at this position
		if furni_by_position.has(hovered_tile):
			# Get the furniture sprite
			var furni_sprite: FurniSprite = furni_by_position[hovered_tile]
			
			# Remove from scene
			furni_sprite.queue_free()
			
			# Remove from tracking dictionary
			furni_by_position.erase(hovered_tile)
			
			# Update ghost visibility immediately
			update_ghost_visibility()


## Updates ghost furniture visibility based on current hover position
## Used to refresh ghost state without moving the mouse
func update_ghost_visibility() -> void:
	if ghost_furni and hovered_tile != Vector2i(-1, -1):
		# Check if the current hovered tile is valid now
		var is_valid_tile := is_valid_tile_position(hovered_tile)
		
		if is_valid_tile:
			# Show and position ghost furniture on valid tiles
			ghost_furni.position = tile_to_world(hovered_tile)
			ghost_furni.position += ghost_furni.type.visual_offset
			ghost_furni.visible = true
			ghost_furni.modulate = Color(1, 1, 1, 0.5)  # Normal semi-transparent
		else:
			# Hide ghost furniture on invalid tiles
			ghost_furni.visible = false
