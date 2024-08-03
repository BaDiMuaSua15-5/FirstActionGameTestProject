extends Node
class_name PlayerHealthComponent

@onready var HitTimer = $HitTimer

@export var max_health = 10:
	set(value):
		if value < health:
			health = value
			max_health = value
		else:
			max_health = value

var vulnerable: bool = true

signal health_change
@export var health: float = 10.0:
	set(value):
		if (value > health):
			health = min(value, max_health)
		else:
			if vulnerable:
				health = max(value, 0)
				vulnerable = false
				hit_timer(0.2)
			if health == 0:
				print('out health')
				owner.is_dead = true
				owner.set_physics_process(false)
				owner.modulate = "ff0000"
		health_change.emit(health, max_health)

func hit_timer(sec: float):
	await get_tree().create_timer(sec).timeout
	vulnerable = true
