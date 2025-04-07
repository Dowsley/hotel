class_name Main extends Node2D


enum InputModes {
	PLACE,
	SELECT,
}


@onready var furni_option_button: OptionButton = %FurniOptionButton


@export var furni_types_path: StringName = "res://data/furni_types"
@export var curr_room: Room


var furni_types: Array[FurniType] = []
var hovered_tile: Vector2i = Vector2i(-1, -1)
var ghost_furni: FurniSprite = null
var current_input_handler: InputHandler


func _ready() -> void:
	assert(curr_room != null, "Must have starting room.")

	load_furni_types()
	populate_option_button()
	
	furni_option_button.selected = 0
	_on_furni_option_button_item_selected(0)
	
	set_input_handler(InputModes.PLACE)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			var next_mode := InputModes.PLACE if current_input_handler is SelectingInputHandler else InputModes.SELECT
			set_input_handler(next_mode)
			get_viewport().set_input_as_handled()
			return
			
	#if event is InputEventMouseButton and event.pressed:
		#match event.button_index:
			#MOUSE_BUTTON_WHEEL_UP:
				#zoom_camera(-zoom_step)
			#MOUSE_BUTTON_WHEEL_DOWN:
				#zoom_camera(zoom_step)
	
	var command := current_input_handler.handle_input(event)
	
	if command:
		var success := CommandRegistry.execute_command(command, self)
		
		if success and current_input_handler:
			current_input_handler.on_hover_tile_changed(hovered_tile)


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered_tile := curr_room.world_to_tile(mouse_pos)
	
	if new_hovered_tile != hovered_tile:
		hovered_tile = new_hovered_tile
		current_input_handler.on_hover_tile_changed(hovered_tile)


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
	ghost_furni.modulate = Color(1, 1, 1, 0.5)
	ghost_furni.z_index = 100
	curr_room.add_child(ghost_furni)
	
	if current_input_handler:
		current_input_handler.on_furniture_selected()


#func zoom_camera(zoom_amount: float) -> void:
	#if camera:
		#var current_zoom := camera.zoom.x
		#var new_zoom: float = clamp(current_zoom - zoom_amount, min_zoom, max_zoom)
		#camera.zoom = Vector2(new_zoom, new_zoom)


func rotate_ghost_furniture() -> void:
	if ghost_furni:
		ghost_furni.rotate_to_next_frame()


func update_ghost_at_tile(tile: Vector2i) -> void:
	if ghost_furni:
		curr_room.update_ghost_at_tile(ghost_furni, tile)


func set_input_handler(mode: InputModes) -> void:
	if current_input_handler:
		current_input_handler.exit()
	
	match mode:
		InputModes.PLACE:
			current_input_handler = PlacingInputHandler.new(self)
		InputModes.SELECT:
			current_input_handler = SelectingInputHandler.new(self)
	
	current_input_handler.enter()
