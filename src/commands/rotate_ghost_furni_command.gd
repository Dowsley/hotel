class_name RotateGhostFurniCommand extends Command


func execute(main: Main) -> bool:
	main.rotate_ghost_furniture()
	main.update_ghost_at_tile(main.hovered_tile)
	return true

	
func can_execute(main: Main) -> bool:
	return main.ghost_furni != null 
