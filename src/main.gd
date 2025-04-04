extends Node2D


@onready var furni_option_button: OptionButton = %FurniOptionButton
@onready var camera: Camera2D = $Camera2D


@export var furni_types_path: StringName = "res://data/furni_types"
@export var curr_room: Room
@export var min_zoom: float = 1.0  # Maximum zoom in
@export var max_zoom: float = 4.0  # Maximum zoom out
@export var zoom_step: float = 0.1  # How much to zoom per scroll


var furni_types: Array[FurniType] = []
var hovered_tile: Vector2i = Vector2i(-1, -1)
var ghost_furni: FurniSprite = null


func _ready() -> void:
	assert(curr_room != null, "Must have starting room.")

	load_furni_types()
	populate_option_button()
	
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

	# Set a high z_index to ensure it's always on top of other furniture
	ghost_furni.z_index = 100
	add_child(ghost_furni)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_furniture_at_mouse()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			remove_furniture_at_mouse()
		
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(-zoom_step)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(zoom_step)


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered_tile := curr_room.world_to_tile(mouse_pos)
	
	# Only update if the hovered tile has changed
	if new_hovered_tile != hovered_tile:
		hovered_tile = new_hovered_tile
		
		# Update ghost and grid marker in the room
		curr_room.update_ghost_at_tile(ghost_furni, hovered_tile)
	
	if Input.is_action_just_pressed("furni_rotate"):
		rotate_ghost_furniture()
		curr_room.update_ghost_at_tile(ghost_furni, hovered_tile)

	if Input.is_action_just_pressed("furni_select_next_variation"):
		curr_room.switch_variation_at_position(hovered_tile)
		curr_room.update_ghost_at_tile(ghost_furni, hovered_tile)


func zoom_camera(zoom_amount: float) -> void:
	if camera:
		var current_zoom := camera.zoom.x
		var new_zoom: float = clamp(current_zoom - zoom_amount, min_zoom, max_zoom)
		camera.zoom = Vector2(new_zoom, new_zoom)


func place_furniture_at_mouse() -> void:
	if ghost_furni and ghost_furni.visible:
		var selected_index: int = furni_option_button.get_selected_id()
		if selected_index != -1:
			var rotation_frame: int = ghost_furni.current_rotation_frame
			
			# Delegate to the room to place furniture
			curr_room.place_furniture(ghost_furni, hovered_tile, rotation_frame)


func remove_furniture_at_mouse() -> void:
	if curr_room.remove_furniture(hovered_tile):
		# Update ghost visibility after removal
		curr_room.update_ghost_at_tile(ghost_furni, hovered_tile)


func rotate_ghost_furniture() -> void:
	if ghost_furni:
		ghost_furni.rotate_to_next_frame()
