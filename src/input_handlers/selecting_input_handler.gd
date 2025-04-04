class_name SelectingInputHandler extends InputHandler
## State for switching furniture variations


var selected_furniture: FurniSprite
var last_click_time: int = 0
var double_click_threshold: int = 300  # Milliseconds


func enter() -> void:
	if main.ghost_furni:
		main.ghost_furni.visible = false


func exit() -> void:
	# Clear any selection state when exiting
	selected_furniture = null


func handle_input(event: InputEvent) -> Command:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var current_time := Time.get_ticks_msec()
				var tile_position := main.hovered_tile
				var furniture := main.curr_room.get_furniture_at_tile(tile_position)
				
				if furniture:
					# Check for double click
					if selected_furniture == furniture and (current_time - last_click_time) < double_click_threshold:
						# Double click detected - return switch variation command
						selected_furniture = furniture
						last_click_time = current_time
						# Use autoloaded CommandRegistry
						return CommandRegistry.create_variation_command(tile_position)
					else:
						# Single click - just select
						selected_furniture = furniture
						last_click_time = current_time
				else:
					selected_furniture = null
			
			MOUSE_BUTTON_RIGHT:
				if selected_furniture:
					selected_furniture = null
	
	return null


func on_hover_tile_changed(tile: Vector2i) -> void:
	# Only update grid markers in selection mode, keep ghost invisible
	main.curr_room.update_grid_markers_at_tile(tile, main.ghost_furni)


func on_furniture_selected() -> void:
	# Keep ghost hidden in this mode even when selecting from dropdown
	if main.ghost_furni:
		main.ghost_furni.visible = false
