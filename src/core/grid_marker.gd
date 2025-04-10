@tool
class_name GridMarker extends Node2D


var tile_size: Vector2 = Vector2(32, 16)  # Default tile size, will be updated
var color := Color(1, 1, 0, 1)


func _ready() -> void:
	z_index = 10 # Make sure this node is always drawn on top
	top_level = false # Remove top_level to allow the marker to inherit parent's scale


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Get the parent scale to make sure we draw at the correct size
	var parent_node := get_parent()
	var parent_scale := Vector2.ONE
	if parent_node:
		parent_scale = parent_node.global_transform.get_scale()
	
	# Define the diamond points based on tile size
	var points := []
	points.append(Vector2(0, -tile_size.y/2))          # Top
	points.append(Vector2(tile_size.x/2, 0))           # Right
	points.append(Vector2(0, tile_size.y/2))           # Bottom
	points.append(Vector2(-tile_size.x/2, 0))          # Left
	points.append(Vector2(0, -tile_size.y/2))          # Back to top (close the shape)
	
	# Draw the diamond outline - adjust line width based on parent scale
	var line_width: float = 2.0 / max(parent_scale.x, 0.01)
	draw_polyline(points, color, line_width, true)
	
	# Optional: Draw the center point for reference
	#draw_circle(Vector2.ZERO, 3, Color(1, 0, 0, 1))
	
	# Optional: Fill the diamond with a semi-transparent color
	draw_colored_polygon(points, Color(color, 0.2))
