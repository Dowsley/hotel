class_name SelectedFurniWindow extends Panel


@onready var furni_icon: FurniSprite = %FurniIcon
@onready var title_label: Label = %TitleLabel

var furni_type: FurniType


func setup(ft: FurniType) -> void:
	furni_type = ft
	
	var sprite := ft.create()
	var frame_image := GraphicsUtil.get_current_sprite_frame_texture(sprite)
	var cropped := GraphicsUtil.crop_to_used_rect(frame_image)
	var resized := GraphicsUtil.resize_image_texture_to(cropped, 32, 32)
	furni_icon.texture = resized
	title_label.text = ft.name
	show()


func _on_use_button_pressed() -> void:
	Inventory.furni_selected.emit(furni_type)
	hide()


func _on_turn_button_pressed() -> void:
	pass


func _on_move_button_pressed() -> void:
	# Switch to placing mode with this furniture
	Inventory.furni_selected.emit(furni_type)
	hide()


func _on_close_button_pressed() -> void:
	hide()
