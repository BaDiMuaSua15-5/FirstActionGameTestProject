extends Node
class_name HealthComponent

@onready var HitTimer = $HitTimer

@export var max_health = 10

var vulnerable: bool = true

@export var health: float = 20.0:
	set(value):
		if (value > health):
			health = min(value, max_health)
		else:
			if vulnerable:
				health = max(value, 0)
				vulnerable = false
				hit_timer(0.2)
			if health == 0:
				owner.is_dead = true
				owner.set_physics_process(false)
				owner.modulate = "ff0000"
				owner.queue_free()

func hit_timer(sec: float):
	await get_tree().create_timer(sec).timeout
	vulnerable = true
