extends Node


signal furni_selected(ft: FurniType)


var furnis: Dictionary[FurniType, int] = {}


## For now it's only a mock.
func _ready() -> void:
	for ft: FurniType in Catalog.furni_types:
		furnis[ft] = 99
