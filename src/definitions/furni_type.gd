@tool
class_name FurniType extends Resource

@export var name: StringName

## Number of rows in the spritesheet. Represents the amount of different angles a Furniture has. For now the default is 4.
## Therefore, advancing the coordinate 'y' in framecoords will lead to rotation.
const VFRAMES := 4


@export var sprite_sheet: Texture2D

## Number of columns in the spritesheet. Represents an animation. 1 means static.
## Therefore, advancing the coordinate 'x' in framecoords will lead to animation.
@export var hframes := 1
@export var default_rotation_frame := 0

## Visual offset for placement (y-offset) - mainly for vertical alignment
@export var visual_offset: Vector2 = Vector2(0, -24) # -16*1.5. Made sense at some point but I forgot why.

## Y-sort origin offset for proper depth sorting
## A higher value will push the object more to the back (draw earlier)
## Default is 0, meaning it will use the sprite's default y-sort position
@export var y_sort_origin: float = 0.0

@export var frame_time_ms: float = 200.0


func create() -> FurniSprite:
	var sprite := FurniSprite.new()
	sprite.type = self  # This has a setter that will set it up internally.
	return sprite
