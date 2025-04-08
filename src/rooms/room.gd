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
	
	# Reset furniture container transform to avoid scaling issues
	if furniture_container:
		furniture_container.position = Vector2.ZERO
		furniture_container.scale = Vector2.ONE
		
		# Ensure the furniture container is properly set up for visibility
		furniture_container.z_index = 1 # Above the floor/grid but below UI
		furniture_container.y_sort_enabled = true


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
	for i in 16: # TODO: Dynamically calculate this based on largest furniture
		var gm := create_grid_marker()
		gm.hide()
		grid_marker_pool.append(gm)


## Updates ghost furniture visibility based on current hover position
func update_ghost_at_tile(ghost: FurniSprite, tile_pos: Vector2i) -> void:
	var can_place := update_grid_markers_at_tile(tile_pos, ghost)
	update_ghost_visibility(ghost, tile_pos, can_place)


## Updates only the grid markers for a given tile position and furniture
## Returns whether placement is valid
func update_grid_markers_at_tile(tile_pos: Vector2i, furni: FurniSprite) -> bool:
	var can_place_tile := true
	var positions_to_occupy := get_positions_furni_will_occupy(tile_pos, furni) 
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
			# Use local coordinates for the grid markers since they're children of this node
			var local_pos := tile_to_local(p)
			gm.position = local_pos
			gm.visible = true
			
			can_place_tile = can_place_tile && is_valid_pos
		else:
			gm.visible = false
		i += 1
	
	return can_place_tile


## Updates only the ghost furniture visibility
func update_ghost_visibility(ghost: FurniSprite, tile_pos: Vector2i, can_place: bool) -> void:
	if can_place:
		# Use local coordinates since ghost is a child of this node
		ghost.position = tile_to_local(tile_pos)
		ghost.position += ghost.type.visual_offset
		ghost.visible = true
	else:
		ghost.visible = false

func get_furniture_at_tile(tile_pos: Vector2i) -> FurniSprite:
	return furni_by_position.get(tile_pos)
	

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
		var furni_sprite := furni_type.create()
		
		var local_pos := tile_to_local(tile_pos)
		
		# Adjust coordinates for furniture container if needed
		if furniture_container != self:
			local_pos = furniture_container.to_local(to_global(local_pos))
			
		furni_sprite.position = local_pos
		furni_sprite.position += furni_type.visual_offset
		furni_sprite.visible = true
		
		# Ensure proper z-index sorting
		furni_sprite.current_rotation_frame = rotation_frame
		furni_sprite.z_index = max(1, furni_sprite.z_index)
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
	
	furni.switch_variation_to_next()
	furni.refresh()
	
	# Ensure the furniture remains visible after variation change
	furni.visible = true
	# Ensure z-index is maintained properly
	furni.z_index = max(1, furni.z_index)
	
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
	var local_pos := to_local(world_pos)
	return floor_tile_map.local_to_map(local_pos)


## Convert tile coordinates to local node position
func tile_to_local(tile_pos: Vector2i) -> Vector2:
	return floor_tile_map.map_to_local(tile_pos)


## Convert tile coordinates to world position
func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return to_global(tile_to_local(tile_pos))


## Better to consolidate logic here, even if it's "slow"
func get_positions_furni_will_occupy(curr_tile_pos: Vector2i, furni: FurniSprite) -> Array[Vector2i]:
	var bound_start := curr_tile_pos
	var bound_end := curr_tile_pos + furni.get_area_extends_by()
	var x_start: int = min(bound_start.x, bound_end.x)
	var x_end: int = max(bound_start.x, bound_end.x)
	var y_start: int = min(bound_start.y, bound_end.y)
	var y_end: int = max(bound_start.y, bound_end.y)
	
	var results: Array[Vector2i] = []
	for x in range(x_start, x_end + 1):
		for y in range(y_start, y_end + 1):
			results.append(Vector2i(x, y))
	return results
