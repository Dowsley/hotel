class_name SwitchFurnitureVariationCommand extends Command


var tile_position: Vector2i


func _init(pos: Vector2i) -> void:
	tile_position = pos

	
func execute(main: Main) -> bool:
	return main.curr_room.switch_variation_at_position(tile_position)


func can_execute(main: Main) -> bool:
	return main.curr_room.get_furniture_at_tile(tile_position) != null
