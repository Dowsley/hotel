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
		set_rotation_frame(current_rotation_frame)

## Maps to frame_coords.x
var current_anim_frame := 0
var animation_timer := 0.0


func _ready() -> void:
	assert(type != null, "Error: Can't create furni with no type.")


func _process(delta: float) -> void:
	animation_timer += delta * 1000
	if animation_timer >= type.frame_time_ms:
		animation_timer -= type.frame_time_ms
		current_anim_frame = (current_anim_frame + 1) % type.hframes
		set_animation_frame(current_anim_frame)


func setup(m_type: FurniType) -> void:
	texture = m_type.sprite_sheet
	frame_coords.y = type.default_rotation_frame
	vframes = m_type.vframes
	hframes = m_type.hframes
	
	# Apply custom depth sorting
	# In Godot 4, individual sprites don't have y_sort_origin directly
	# The parent Node2D handles the y-sorting
	if m_type.y_sort_origin != 0.0:
		# Set z_index based on the y position for depth sorting
		# This works when the parent doesn't have y_sort_enabled
		# Otherwise, the parent's y_sort_enabled will handle sorting
		z_index = int(m_type.y_sort_origin)


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
