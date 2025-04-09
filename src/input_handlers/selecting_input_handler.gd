class_name SelectingInputHandler extends InputHandler
## State for switching furniture variations


var selected_furniture: FurniSprite


func enter() -> void:
	if main.ghost_furni:
		main.ghost_furni.visible = false
	
	show_single_grid_marker(main.hovered_tile)


func exit() -> void:
	# Clear any selection state when exiting
	selected_furniture = null


func handle_input(event: InputEvent) -> Command:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var tile_position := main.hovered_tile
				var furniture := main.curr_room.get_furniture_at_tile(tile_position)
				
				if furniture:
					# Check for double click
					if selected_furniture == furniture and event.double_click:
						# Double click detected - return switch variation command
						selected_furniture = furniture
						# Use autoloaded CommandRegistry
						return CommandRegistry.create_variation_command(tile_position)
					else:
						# Single click - just select
						selected_furniture = furniture
				else:
					selected_furniture = null
	
	return null


func on_hover_tile_changed(tile: Vector2i) -> void:
	show_single_grid_marker(tile)


func show_single_grid_marker(tile: Vector2i) -> void:
	var room := main.curr_room
	var grid_markers := room.grid_marker_pool
	
	if grid_markers.size() > 0:
		# Show only the first grid marker at the current tile
		var gm := grid_markers[0]
		gm.color = room.GRID_MARKER_SELECT_COLOR
		gm.position = room.tile_to_local(tile)
		gm.visible = true
		
		# Hide all other markers
		for i in range(1, grid_markers.size()):
			grid_markers[i].visible = false


func on_furniture_selected() -> void:
	# Keep ghost hidden in this mode even when selecting from dropdown
	if main.ghost_furni:
		main.ghost_furni.visible = false
