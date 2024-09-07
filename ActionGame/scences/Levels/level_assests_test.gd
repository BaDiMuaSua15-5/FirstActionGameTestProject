extends LevelClass
class_name AssetTestScene

@export var level_name: String = "asset_test"
var position_node: Node2D
var data_parameters: Dictionary = {"player": null,
									"other": null,}

func _ready() -> void:
	Global.player_hit_sound = ($Sound/HitSound as AudioStreamPlayer2D)
	Global.throwable_break_sound = ($Sound/ThrowBreakSound as AudioStreamPlayer2D)
	Global.throwable_collide_sound = $Sound/ThrowCollideSound as AudioStreamPlayer2D
	Global.player = $ControlledChar
	Global.camera = $ControlledChar/Shakeable_Camera as ShakeableCamera

func _on_next_level_body_entered(body: Node2D) -> void:
	var next_level_name: String
	next_level_name = "level_1"
	data_parameters["player"] = get_node("ControlledChar")
	emit_scene_change(level_name, next_level_name)

func enter_scene(from_scene: String, imported_parameters: Dictionary) -> void:
	match from_scene:
		"level_1":
			position_node = $Areas/next_level/next_level_enter
		_:
			return
	process_parameters(imported_parameters)
	call_deferred("position_player")
	call_deferred("setup_UI")

func process_parameters(imported_param: Dictionary) -> void:
	var current_player := $ControlledChar as PlayerObj
	# remove existing character in scene
	if current_player:
		current_player.name = current_player.name + "2"
		current_player.queue_free()
	imported_param["player"].reparent(self)
	imported_param["player"].set_deferred("name", "ControlledChar")
	Global.player = imported_param["player"]
	Global.camera = (Global.player as PlayerObj).get_node("Shakeable_Camera")

func position_player() -> void:
	var player := get_node("ControlledChar")
	if position_node:
		player.global_position = position_node.global_position

func setup_UI() -> void:
	var player := get_node("ControlledChar")
	$UI.Player = player
	$UI._ready()
