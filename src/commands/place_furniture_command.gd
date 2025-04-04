class_name PlaceFurnitureCommand extends Command


var tile_position: Vector2i
var rotation_frame: int


func _init(pos: Vector2i, rot: int = 0) -> void:
	tile_position = pos
	rotation_frame = rot

	
func execute(main: Main) -> bool:
	if not can_execute(main):
		return false
		
	var ghost: FurniSprite = main.ghost_furni
	return main.curr_room.place_furniture(ghost, tile_position, rotation_frame)

	
func can_execute(main: Main) -> bool:
	if not main.ghost_furni or not main.ghost_furni.visible:
		return false
	return true 