class_name InvSlot extends Panel


signal furni_slot_selected(slot: InvSlot)


@onready var icon: Sprite2D = %Icon
@onready var amount_label: Label = $AmountLabel


var furni_type: FurniType
var _amount: int


func set_furni(ft: FurniType, m_amount: int) -> void:
	furni_type = ft
	_amount = m_amount
	amount_label.text = str(m_amount)
	
	var sprite := ft.create()
	var frame_image := GraphicsUtil.get_current_sprite_frame_texture(sprite)
	var cropped := GraphicsUtil.crop_to_used_rect(frame_image)
	var resized := GraphicsUtil.resize_image_texture_to(cropped, 32, 32)
	icon.texture = resized


func select() -> void:
	var style := get("theme_override_styles/panel") as StyleBoxFlat
	style.set_border_width_all(2)
	queue_redraw()


func unselect() -> void:
	var style := get("theme_override_styles/panel") as StyleBoxFlat
	style.set_border_width_all(1)
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		furni_slot_selected.emit(self)
