extends Node

var is_dragging: bool = false
var is_on_draggable: bool = false


func hitstop_effect(time_scale:float, duration: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
