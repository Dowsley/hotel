class_name SelectedFurniWindow extends VBoxContainer


signal furniture_variation_requested(position: Vector2i)
signal furniture_rotation_requested(position: Vector2i)


@onready var furni_icon: Sprite2D = %FurniIcon
@onready var title_label: Label = %TitleLabel


var selected_furni: FurniSprite


func setup(furni: FurniSprite) -> void:
	selected_furni = furni
	
	var frame_image := GraphicsUtil.get_current_sprite_frame_texture(furni)
	var cropped := GraphicsUtil.crop_to_used_rect(frame_image)
	var resized_img := GraphicsUtil.resize_image_texture_to(cropped, 32, 32)
	furni_icon.texture = resized_img
	title_label.text = furni.type.name
	show()


func _on_use_button_pressed() -> void:
	var pos := selected_furni.occupied_positions[0]
	furniture_variation_requested.emit(pos)


func _on_turn_button_pressed() -> void:
	var pos := selected_furni.occupied_positions[0]
	furniture_rotation_requested.emit(pos)


func _on_move_button_pressed() -> void:
	Inventory.furni_selected.emit(selected_furni.type)
	hide()


func _on_close_button_pressed() -> void:
	hide()
