class_name RotateFurnitureCommand extends Command


func execute(main: Main) -> bool:
	if not can_execute(main):
		return false
		
	main.rotate_ghost_furniture()
	main.update_ghost_at_tile(main.hovered_tile)
	return true

	
func can_execute(main: Main) -> bool:
	return main.ghost_furni != null 