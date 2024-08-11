extends Node
class_name HealthComponent

@export var HitTimer: Timer

@export var max_health: int = 1000
@export var OwnerEntity: CollisionObject2D

var vulnerable: bool = true

@export var health: float = 20.0:
	set(value):
		if (value > health):
			health = min(value, max_health)
		else:
			if vulnerable:
				health = max(value, 0)
				vulnerable = false
				HitTimer.start()
			if health == 0:
				owner.is_dead = true
				owner.set_physics_process(false)
				owner.modulate = "ff0000"
				owner.queue_free()



func _on_hit_timer_timeout() -> void:
	vulnerable = true
