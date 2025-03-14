@tool
class_name GridMarker extends Node2D


var tile_size: Vector2 = Vector2(32, 16)  # Default tile size, will be updated


func _ready() -> void:
	z_index = 10 # Make sure this node is always drawn on top


func _process(_delta: float) -> void:
	queue_redraw() # Ensure it's always redrawn


func _draw() -> void:
	# Define the diamond points based on tile size
	var points := []
	points.append(Vector2(0, -tile_size.y/2))          # Top
	points.append(Vector2(tile_size.x/2, 0))           # Right
	points.append(Vector2(0, tile_size.y/2))           # Bottom
	points.append(Vector2(-tile_size.x/2, 0))          # Left
	points.append(Vector2(0, -tile_size.y/2))          # Back to top (close the shape)
	
	# Draw the diamond outline with a nice yellow color
	draw_polyline(points, Color(1, 1, 0, 1), 2.0, true)
	
	# Optional: Draw the center point for reference
	#draw_circle(Vector2.ZERO, 3, Color(1, 0, 0, 1))
	
	# Optional: Fill the diamond with a semi-transparent color
	draw_colored_polygon(points, Color(1, 1, 0, 0.2))
