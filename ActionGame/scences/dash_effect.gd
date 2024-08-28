extends Node2D
class_name DashEffect

func _ready() -> void:
	ghosting()

func set_property(txt_pos: Vector2, txt_scale: Vector2) -> void:
	scale = txt_scale
	position = txt_pos
	
func ghosting() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.75)
	
	await tween.finished
	queue_free()
