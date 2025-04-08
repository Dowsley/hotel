class_name Main extends Node2D


enum InputModes {
	PLACE,
	SELECT,
}


@export var curr_room: Room

@onready var inv_window: InventoryWindow = %InventoryWindow


var hovered_tile: Vector2i = Vector2i(-1, -1)
var ghost_furni: FurniSprite = null
var current_input_handler: InputHandler


func _ready() -> void:
	set_input_handler(InputModes.SELECT)
	inv_window.close_button_pressed.connect(_on_inventory_closed_button_pressed)
	Inventory.furni_selected.connect(_on_furni_option_button_item_selected)
	

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


func _on_furni_option_button_item_selected(ft: FurniType) -> void:
	set_input_handler(InputModes.PLACE)
	if ghost_furni:
		ghost_furni.queue_free()

	ghost_furni = ft.create()
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


func _on_inventory_button_pressed() -> void:
	inv_window.visible = not inv_window.visible


func _on_inventory_closed_button_pressed() -> void:
	inv_window.hide()
