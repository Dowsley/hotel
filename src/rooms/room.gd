class_name Room extends Node2D


const GRID_MARKER_AVAILABLE_COLOR := Color(1, 1, 0)
const GRID_MARKER_OCCUPIED_COLOR := Color(1, 0, 0)


## Container for all furniture with Y-sorting
@onready var furniture_container: Node2D = $FurnitureContainer
@onready var walls_tile_map: TileMapLayer = $Walls
@onready var floor_tile_map: TileMapLayer = $Floor


## Dictionary to track where furniture are placed
var furni_by_position: Dictionary[Vector2i, FurniSprite] = {}

## Grid visualization
var grid_marker_pool: Array[GridMarker] = []


func _ready() -> void:
	setup_grid_markers()


## Creates a dedicated node for showing the grid highlight
func create_grid_marker() -> GridMarker:
	var gm := GridMarker.new()
	gm.tile_size = floor_tile_map.tile_set.tile_size
	add_child(gm)
	return gm


## Sets up the pool of grid markers and the main one.
## Benefit of having a pool is obvious: We don't want to create and free them at request.
## We will create an arbitrary number here: 16 (represents a 4x4 furni at max)
func setup_grid_markers() -> void:
	for i in 16: # TODO: Calculate dynamically based on largest Furni
		var gm := create_grid_marker()
		gm.hide()
		grid_marker_pool.append(gm)


## Updates ghost furniture visibility based on current hover position
func update_ghost_at_tile(ghost: FurniSprite, tile_pos: Vector2i) -> void:
		var can_place_tile := true
		var positions_to_occupy := get_positions_furni_will_occupy(tile_pos, ghost)
		var n_positions := positions_to_occupy.size()
		var n_grid_markers := grid_marker_pool.size()
		
		# Update grid markers
		var i := 0
		while i < n_grid_markers:
			var gm := grid_marker_pool[i]
			if i < n_positions:
				var p := positions_to_occupy[i]
				var is_valid_pos := is_valid_tile_position(p)
				gm.color = GRID_MARKER_AVAILABLE_COLOR if is_valid_pos else GRID_MARKER_OCCUPIED_COLOR
				gm.position = tile_to_world(p)
				gm.visible = true
				
				can_place_tile = can_place_tile && is_valid_pos
			else:
				gm.visible = false
			i += 1
		
		# Update ghost
		if can_place_tile:
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
func place_furniture(ghost_furni: FurniSprite, tile_pos: Vector2i, rotation_frame: int = 0) -> bool:
	if is_valid_tile_position(tile_pos):
		var furni_type := ghost_furni.type
		var furni_sprite: FurniSprite = furni_type.create()
		
		var tile_center_world := floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))
		
		furni_sprite.position = tile_center_world
		furni_sprite.position += furni_type.visual_offset
		furni_sprite.current_rotation_frame = rotation_frame
		furniture_container.add_child(furni_sprite)

		var positions := get_positions_furni_will_occupy(tile_pos, furni_sprite)
		for p in positions:
			furni_by_position[p] = furni_sprite
			furni_sprite.occupied_positions.append(p)
		
		update_ghost_at_tile(ghost_furni, tile_pos)
		return true
	
	return false


## Attempts to switch the variation of the mobi under pos.
## Will return true if successful (furni exists).
## If furni has only one variation, switching will technically be successful.
func switch_variation_at_position(pos: Vector2i) -> bool:
	var furni := furni_by_position.get(pos) as FurniSprite
	if not furni:
		return false
	
	furni.curr_variation += 1
	furni.refresh()
	return true


## Remove furniture at the specified tile position
func remove_furniture(tile_pos: Vector2i) -> bool:
	if furni_by_position.has(tile_pos):
		var furni_sprite: FurniSprite = furni_by_position[tile_pos]
		for pos in furni_sprite.occupied_positions:
			furni_by_position.erase(pos)
		
		furni_sprite.queue_free()
		
		return true
	
	return false


## Convert world position to tile coordinates
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return floor_tile_map.local_to_map(floor_tile_map.to_local(world_pos))


## Convert tile coordinates to world position
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.to_global(floor_tile_map.map_to_local(tile_pos))


## Better to consolidate logic here, even if it's "slow"
func get_positions_furni_will_occupy(curr_tile_pos: Vector2i, furni: FurniSprite) -> Array[Vector2i]:
	var bound_start := curr_tile_pos
	var bound_end := curr_tile_pos + furni.get_area_extends_by()
	var x_start: int = min(bound_start.x, bound_end.x)
	var x_end: int = max(bound_start.x, bound_end.x)
	var y_start: int = min(bound_start.y, bound_end.y)
	var y_end: int = max(bound_start.y, bound_end.y)
	
	var results: Array[Vector2i] = []
	# Add 1 to the end values to ensure at least one iteration even when start == end
	for x in range(x_start, x_end + 1):
		for y in range(y_start, y_end + 1):
			var pos := Vector2i(x, y)
			results.append(pos)
	return results
