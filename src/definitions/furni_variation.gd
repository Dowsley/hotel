class_name FurniVariation extends Resource


@export var sprite_sheet: Texture2D
## Number of columns in the spritesheet. Represents an animation. 1 means static.
## Therefore, advancing the coordinate 'x' in framecoords will lead to animation.
@export var hframes := 1
@export var frame_time_ms: float = 200.0
