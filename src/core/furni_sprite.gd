@tool
class_name FurniSprite extends Sprite2D


@export var type: FurniType:
	set(value):
		type = value
		setup(type)

## Maps to frame_coords.x
@export var current_rotation_frame := 0:
	set(value):
		current_rotation_frame = max(min(value, type.VFRAMES-1), 0)
		set_rotation_frame(current_rotation_frame)

@export var frame_time_ms: float = 200.0

var current_anim_frame := 0
var animation_timer: float = 0.0


func _ready() -> void:
	assert(type != null, "Error: Can't create furni with no type.")


func _process(delta: float) -> void:
	animation_timer += delta * 1000
	if animation_timer >= frame_time_ms:
		animation_timer -= frame_time_ms
		current_anim_frame = (current_anim_frame + 1) % type.hframes
		set_animation_frame(current_anim_frame)


func setup(type: FurniType) -> void:
	texture = type.sprite_sheet
	frame_coords.x = type.default_rotation_frame
	vframes = type.VFRAMES
	hframes = type.hframes


func set_rotation_frame(target_v_frame: int) -> void:
	frame_coords.y = target_v_frame


func set_animation_frame(target_h_frame: int) -> void:
	frame_coords.x = target_h_frame
