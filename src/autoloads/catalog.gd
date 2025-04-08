extends Node


const FURNI_DATA_PATH: StringName = "res://data/furni_types"


var furni_types: Array[FurniType] = []


func _ready() -> void:
	load_furni_types()


func load_furni_types() -> void:
	var dir: DirAccess = DirAccess.open(FURNI_DATA_PATH)
	assert(dir != null, "Failed to open directory: " + FURNI_DATA_PATH)

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var ft: FurniType = load(FURNI_DATA_PATH + "/" + file_name)
			if ft != null:
				furni_types.append(ft)
		file_name = dir.get_next()
