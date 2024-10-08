extends LevelClass
class_name level_1Scene

@export var level_name: String = "level_1"
var position_node: Node2D
var data_parameters: Dictionary = {"player": null,
									"other": null,}

func _ready() -> void:
	Global.player_hit_sound = ($Sound/HitSound as AudioStreamPlayer2D)
	Global.throwable_break_sound = ($Sound/ThrowBreakSound as AudioStreamPlayer2D)
	Global.throwable_collide_sound = $Sound/ThrowCollideSound as AudioStreamPlayer2D
	Global.player = $ControlledChar
	Global.camera = $ControlledChar/Shakeable_Camera as ShakeableCamera


func _on_previous_level_body_entered(body: Node2D) -> void:
	var previous_level_name: String = "level_assests_test"
	data_parameters["player"] = get_node("ControlledChar")
	emit_scene_change(level_name, previous_level_name)

func enter_scene(from_scene: String, imported_parameters: Dictionary) -> void:
	match from_scene:
		"asset_test":
			position_node = $Areas/previous_level/PositionNode
		_:
			return
	process_parameters(imported_parameters)
	call_deferred("position_player")
	call_deferred("setup_UI")

func process_parameters(imported_param: Dictionary) -> void:
	var current_player := $ControlledChar as PlayerObj
	if current_player:
		current_player.name = current_player.name + "2"
		current_player.queue_free()
	#call_deferred("add_child", imported_param["player"])
	imported_param["player"].reparent(self)
	imported_param["player"].set_deferred("name", "ControlledChar")

func position_player() -> void:
	var player := get_node("ControlledChar")
	if position_node:
		player.global_position = position_node.global_position

func setup_UI() -> void:
	var player := get_node("ControlledChar")
	$UI.Player = player
	$UI._ready()
