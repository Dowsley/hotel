class_name Room extends Node2D


## Container for all furniture with Y-sorting
@onready var furniture_container: Node2D = $FurnitureContainer
@onready var walls_tile_map: TileMapLayer = $Walls
@onready var floor_tile_map: TileMapLayer = $Floor


## Dictionary to track furniture by position
## Key: Vector2i (tile position), Value: FurniSprite
var furni_by_position: Dictionary = {}

## For furniture preview
var ghost_furni: FurniSprite = null

## Grid visualization
var grid_marker: Node2D = null


func _ready() -> void:
	create_grid_marker()


## Creates a dedicated node for showing the grid highlight
func create_grid_marker() -> void:
	grid_marker = GridMarker.new()
	add_child(grid_marker)
	
	if floor_tile_map and floor_tile_map.tile_set:
		grid_marker.tile_size = floor_tile_map.tile_set.tile_size


## Updates ghost furniture visibility based on current hover position
func update_ghost_at_tile(ghost: FurniSprite, tile_pos: Vector2i) -> void:
	var is_valid_tile := is_valid_tile_position(tile_pos)
	
	# Update grid marker
	if grid_marker:
		if is_valid_tile:
			var tile_center_world := floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))
			grid_marker.position = tile_center_world
			grid_marker.visible = true
		else:
			grid_marker.visible = false
	
	# Update ghost furniture
	if ghost:
		if is_valid_tile:
			ghost.position = tile_to_world(tile_pos)
			ghost.position += ghost.type.visual_offset
			ghost.visible = true
		else:
			ghost.visible = false


## Check if a tile position is valid for placing furniture
func is_valid_tile_position(tile_pos: Vector2i) -> bool:
	if floor_tile_map.get_cell_source_id(tile_pos) < 0:
		return false
	
	if furni_by_position.has(tile_pos):
		return false
	
	return true


## Place furniture at the specified tile position
func place_furniture(furni_type: FurniType, tile_pos: Vector2i, rotation_frame: int = 0) -> bool:
	if is_valid_tile_position(tile_pos):
		var furni_sprite: FurniSprite = furni_type.create()
		
		var tile_center_world := floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))
		
		furni_sprite.position = tile_center_world
		furni_sprite.position += furni_type.visual_offset
		furni_sprite.current_rotation_frame = rotation_frame
		furniture_container.add_child(furni_sprite)
		furni_by_position[tile_pos] = furni_sprite
		
		return true
	
	return false


## Remove furniture at the specified tile position
func remove_furniture(tile_pos: Vector2i) -> bool:
	if furni_by_position.has(tile_pos):
		var furni_sprite: FurniSprite = furni_by_position[tile_pos]
		furni_sprite.queue_free()
		furni_by_position.erase(tile_pos)
		
		return true
	
	return false


## Convert world position to tile coordinates
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return floor_tile_map.local_to_map(floor_tile_map.to_local(world_pos))


## Convert tile coordinates to world position
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))
