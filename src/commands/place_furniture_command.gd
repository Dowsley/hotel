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
	var furni_type := ghost.type
	
	# Place the furniture
	var success := main.curr_room.place_furniture(ghost, tile_position, rotation_frame)
	if success:
		# Consume the furniture from inventory
		Inventory.consume(furni_type)
		return true
	
	return false

	
func can_execute(main: Main) -> bool:
	if not main.ghost_furni or not main.ghost_furni.visible:
		return false
		
	# Check if we have this furniture in inventory using centralized logic
	return Inventory.has_available(main.ghost_furni.type) 