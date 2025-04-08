@tool
class_name FurniSprite extends Sprite2D


@export var type: FurniType:
	set(value):
		type = value
		setup(type)

## Maps to frame_coords.x
@export var current_rotation_frame := 0:
	set(value):
		current_rotation_frame = max(min(value, type.vframes-1), 0)
		curr_variation = 0
		set_rotation_frame(current_rotation_frame)
		update_sorting()  # Update sorting when rotation changes


var animation_timer := 0.0
## Maps to frame_coords.x
var current_anim_frame := 0
var occupied_positions: Array[Vector2i] = []

var curr_variation: int = 0:
	set(value):
		var count = type.variations.size()
		if count > 0:
			curr_variation = (value % count + count) % count  # ensures wraparound for negative values too
		else:
			curr_variation = 0  # fallback if no variations

func _ready() -> void:
	assert(type != null, "Error: Can't create furni with no type.")


func _process(delta: float) -> void:
	animation_timer += delta * 1000
	if animation_timer >= type.get_variation(curr_variation).frame_time_ms:
		animation_timer -= type.get_variation(curr_variation).frame_time_ms
		current_anim_frame = (current_anim_frame + 1) % type.get_variation(curr_variation).hframes
		set_animation_frame(current_anim_frame)


func setup(m_type: FurniType) -> void:
	texture = m_type.get_variation(curr_variation).sprite_sheet
	frame_coords.y = type.default_rotation_frame
	vframes = m_type.vframes
	hframes = m_type.get_variation(curr_variation).hframes
	
	# Basic z-index from the type
	if m_type.y_sort_origin != 0:
		z_index = m_type.y_sort_origin
	
	update_sorting()


func refresh() -> void:
	texture = type.get_variation(curr_variation).sprite_sheet
	hframes = type.get_variation(curr_variation).hframes
	
	# Basic z-index from the type
	if type.y_sort_origin != 0:
		z_index = type.y_sort_origin
	
	update_sorting()


## Updates sorting to account for rotation and size.
func update_sorting() -> void:
	# If this is a ghost furniture (z_index is already set to a high value like 100),
	# preserve that high z-index and don't calculate depth 
	if z_index >= 100:
		return
		
	var extends_by := get_area_extends_by()
	
	if extends_by != Vector2i.ZERO:
		# For isometric view, we need to handle different cases based on the furniture's extension
		# Direction matters for proper sorting.
		var base_z := type.y_sort_origin
		
		# In isometric, +y direction is "down and right", -y is "up and left"
		if extends_by.y < 0:
			# Furniture extends upward (e.g., tall cabinet)
			# Make it appear further back by decreasing z-index
			base_z -= abs(extends_by.y) * 10
		elif extends_by.y > 0:
			# Furniture extends downward/forward
			# Make it appear more in front by increasing z-index
			base_z += extends_by.y * 5
		
		# Handle x-axis extensions as well (left/right in isometric)
		if extends_by.x != 0:
			# Apply a smaller adjustment for x-axis
			base_z += extends_by.x * 2
		
		z_index = base_z


func set_rotation_frame(target_v_frame: int) -> void:
	frame_coords.y = target_v_frame


func set_animation_frame(target_h_frame: int) -> void:
	frame_coords.x = target_h_frame


## Rotates the furniture to the next available rotation frame
## Returns the new rotation frame index
func rotate_to_next_frame() -> int:
	# Calculate the next rotation frame (wrap around when reaching max frames)
	var next_rotation := (current_rotation_frame + 1) % type.vframes
	
	# Use the setter which handles bounds checking and applying the visual change
	current_rotation_frame = next_rotation
	
	return current_rotation_frame


## Returns the area in which that furni extends to.
## Applies rotation
func get_area_extends_by() -> Vector2i:
	var r := type.area_extends_by
	if current_rotation_frame % 2 == 1:
		var temp := r.y
		r.y = -r.x
		r.x = -temp
	return r
