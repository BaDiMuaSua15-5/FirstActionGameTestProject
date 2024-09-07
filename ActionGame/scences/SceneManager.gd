extends Node
class_name SceneManager

var current_level: LevelClass

func _ready() -> void:
	current_level = get_child(0) as LevelClass
	current_level.scene_changed.connect(handle_scene_change)
	current_level.scene_changed

func handle_scene_change(_current_level_name: String, next_level_name: String) -> void:
	var next_level_path: String
	#match next_level_name:
		#"test":
			#next_level_path = "res://scences/Levels/level_1.tscn"
		#_:
			#next_level_path = "res://scences/Levels/level_assests_test.tscn"
	next_level_path = "res://scences/Levels/" + next_level_name + ".tscn"
	
	var temp := load(next_level_path)
	var next_level: LevelClass = temp.instantiate() 
	call_deferred("add_child", next_level)
	next_level.scene_changed.connect(handle_scene_change)
	var last_lvl_params := current_level.data_parameters as Dictionary
	next_level.enter_scene(_current_level_name, last_lvl_params)
	current_level.queue_free()
	current_level = next_level
	
