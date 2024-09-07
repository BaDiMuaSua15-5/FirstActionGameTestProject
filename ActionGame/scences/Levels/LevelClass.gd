extends Node
class_name LevelClass

signal scene_changed(current_level_name: String, next_level_name: String)

func emit_scene_change(current_level_name: String, next_level_name: String) -> void:
	scene_changed.emit(current_level_name, next_level_name)
