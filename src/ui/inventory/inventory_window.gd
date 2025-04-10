class_name InventoryWindow extends Panel


signal close_button_pressed


@export var inv_slot_scene: PackedScene

@onready var inv_grid: GridContainer = %InvGrid


var dragging := false
var drag_offset := Vector2.ZERO
var selected_slot: InvSlot = null
var slots_by_furni_type: Dictionary = {}


func _ready() -> void:
	for ft: FurniType in Inventory.furnis:
		var inv_slot: InvSlot = inv_slot_scene.instantiate()
		inv_grid.add_child(inv_slot)
		inv_slot.set_furni(ft, Inventory.furnis[ft])
		inv_slot.furni_slot_selected.connect(_on_furni_slot_selected)
		slots_by_furni_type[ft] = inv_slot
	
	# Connect to inventory signals
	Inventory.furni_amount_changed.connect(_on_furni_amount_changed)


func _process(_delta: float) -> void:
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


func _on_furni_slot_selected(slot: InvSlot) -> void:
	Inventory.furni_selected.emit(slot.furni_type)
	if selected_slot:
		slot.unselect()
	slot.select()
	selected_slot = slot


## Update the UI when furniture amount changes
func _on_furni_amount_changed(ft: FurniType, new_amount: int) -> void:
	if slots_by_furni_type.has(ft):
		var slot = slots_by_furni_type[ft]
		slot.set_furni(ft, new_amount)
