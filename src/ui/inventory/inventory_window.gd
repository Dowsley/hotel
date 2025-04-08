class_name InventoryWindow extends Panel


signal close_button_pressed


@export var inv_slot_scene: PackedScene

@onready var inv_grid: GridContainer = %InvGrid


func _ready() -> void:
	for ft: FurniType in Inventory.furnis:
		var inv_slot: InvSlot = inv_slot_scene.instantiate()
		inv_grid.add_child(inv_slot)
		inv_slot.set_furni(ft)


func _on_close_button_pressed() -> void:
	close_button_pressed.emit()
