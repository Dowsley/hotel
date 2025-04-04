class_name Command extends RefCounted


func execute(_main: Main) -> bool:
	push_error("Command.execute() is abstract")
	return false


func can_execute(_main: Main) -> bool:
	return true

