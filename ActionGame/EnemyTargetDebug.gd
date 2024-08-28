extends Node2D

@export var Enemy: EnemyObj

func _draw() -> void:
	if Enemy == null:
		return	
	
	var circle_pos := Enemy.target_pos - global_position
	draw_circle(circle_pos.rotated(-global_rotation), 5.0, Color.DARK_ORANGE)
	return

func _physics_process(delta: float) -> void:
	
	queue_redraw()
	return
