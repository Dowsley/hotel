extends Node


signal furni_selected(ft: FurniType)
signal furni_amount_changed(ft: FurniType, new_amount: int)


var furnis: Dictionary[FurniType, int] = {}


## For now it's only a mock.
func _ready() -> void:
	for ft: FurniType in Catalog.furni_types:
		furnis[ft] = 99


## Update the amount of a furniture item and emit the signal
func update_amount(ft: FurniType, amount: int) -> void:
	if furnis.has(ft):
		furnis[ft] = amount
		furni_amount_changed.emit(ft, amount)


## Check if we have enough of a furniture type
func has_available(ft: FurniType, amount: int = 1) -> bool:
	return furnis.has(ft) and furnis[ft] >= amount


## Consume furniture from inventory if available
## Returns true if successful, false if not enough available
func consume(ft: FurniType, amount: int = 1) -> bool:
	if has_available(ft, amount):
		var new_amount := furnis[ft] - amount
		update_amount(ft, new_amount)
		return true
	return false
