class_name PlacingInputHandler extends InputHandler
## State for placing furniture


func enter() -> void:
	if main.ghost_furni:
		main.ghost_furni.visible = true
	main.update_ghost_at_tile(main.hovered_tile)


func exit() -> void:
	if main.ghost_furni:
		main.ghost_furni.visible = false


func handle_input(event: InputEvent) -> Command:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var has_floor := main.curr_room.floor_tile_map.get_cell_source_id(main.hovered_tile) >= 0
				if not has_floor:
					main.set_input_handler(main.InputModes.SELECT)
					return null
				return CommandRegistry.create_place_command(
					main.hovered_tile, 
					main.ghost_furni.current_rotation_frame
				)
	
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_pressed("furni_rotate"):
			return CommandRegistry.create_rotate_command()
		if Input.is_action_just_pressed("exit_mode"):
			main.set_input_handler(main.InputModes.SELECT)
	
	return null


func on_hover_tile_changed(tile: Vector2i) -> void:
	main.update_ghost_at_tile(tile)


func on_furniture_selected() -> void:
	main.update_ghost_at_tile(main.hovered_tile)
