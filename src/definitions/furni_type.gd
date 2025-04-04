@tool
class_name FurniType extends Resource


@export var name: StringName

@export var variations: Array[FurniVariation]
@export var default_variation := 0
@export var default_rotation_frame := 0

## Number of rows in the spritesheet. Represents the amount of different angles a Furniture has.
## Usually 4, but can be 2 in case of big objects.
## Therefore, advancing the coordinate 'y' in framecoords will lead to rotation.
@export var vframes := 4

## Visual offset for placement (y-offset) - mainly for vertical alignment
@export var visual_offset: Vector2 = Vector2(0, -24) # -16*1.5. Made sense at some point but I forgot why.

## Y-sort origin offset for proper depth sorting
## A higher value will push the object more to the back (draw earlier)
## Default is 0, meaning it will use the sprite's default y-sort position
@export var y_sort_origin: int = 0

## How long the area of the Furni extends, and to what direction?
## 0, 0 by default = occupies 1 tile.
## Can be negative, since we have 2 directions for each axis where the furni can extend to.
@export var area_extends_by := Vector2i(0, 0)


func create() -> FurniSprite:
	var sprite := FurniSprite.new()
	sprite.type = self  # This has a setter that will set it up internally.
	return sprite


func get_variation(idx: int) -> FurniVariation:
	return variations[idx]


func get_size() -> Vector2i:
	return area_extends_by.abs()


func get_area() -> int:
	return area_extends_by.x * area_extends_by.y
