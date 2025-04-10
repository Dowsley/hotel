class_name RotateFurnitureCommand extends Command


var tile_position: Vector2i


func _init(pos: Vector2i) -> void:
	tile_position = pos


func execute(main: Main) -> bool:
	var furni_sprite := main.curr_room.get_furniture_at_tile(tile_position) 
	furni_sprite.rotate_to_next_frame()
	return true

	
func can_execute(main: Main) -> bool:
	return main.curr_room.get_furniture_at_tile(tile_position) != null
