extends Node
## Registry that holds all command types and handles command execution
## This should be autoloaded as CommandRegistry


# Placeholder for command history if implementing undo/redo
var command_history: Array[Command] = []


func execute_command(command: Command, executor: Main) -> bool:
	if command == null:
		return false
		
	if command.can_execute(executor):
		var success := command.execute(executor)
		if success:
			# Add to history for potential undo/redo
			command_history.append(command)
		return success
	
	return false


# Create command instances from standard input handlers
func create_place_command(tile_pos: Vector2i, rotation: int) -> Command:
	return PlaceFurnitureCommand.new(tile_pos, rotation)


func create_remove_command(tile_pos: Vector2i) -> Command:
	return RemoveFurnitureCommand.new(tile_pos)


func create_rotate_ghost_furni_command() -> Command:
	return RotateGhostFurniCommand.new()


func create_furniture_rotate_command(tile_pos: Vector2i) -> Command:
	return RotateFurnitureCommand.new(tile_pos)


func create_variation_command(tile_pos: Vector2i) -> Command:
	return SwitchFurnitureVariationCommand.new(tile_pos) 
