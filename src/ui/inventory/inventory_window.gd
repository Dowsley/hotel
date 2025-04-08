class_name InventoryWindow extends Panel


signal close_button_pressed


@export var inv_slot_scene: PackedScene

@onready var inv_grid: GridContainer = %InvGrid


var dragging := false
var drag_offset := Vector2.ZERO


func _ready() -> void:
	for ft: FurniType in Inventory.furnis:
		var inv_slot: InvSlot = inv_slot_scene.instantiate()
		inv_grid.add_child(inv_slot)
		inv_slot.set_furni(ft)


func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset


func _on_close_button_pressed() -> void:
	close_button_pressed.emit()


func _on_draggable_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false
