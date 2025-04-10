class_name InputHandler extends RefCounted


var main: Main


func _init(main_ref: Main) -> void:
	main = main_ref

	
func enter() -> void:
	pass
	
	
func exit() -> void:
	pass
	
	
func handle_input(_event: InputEvent) -> Command:
	return null
	
	
func on_hover_tile_changed(_tile: Vector2i) -> void:
	pass
	
	
func on_furniture_selected() -> void:
	pass
