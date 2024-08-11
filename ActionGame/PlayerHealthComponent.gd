extends Node
class_name PlayerHealthComponent

@onready var HitTimer: Timer = $HitTimer
@export var OwnerEntity: CollisionObject2D

@export var max_health: int = 10:
	set(value):
		if value <= 0:
			print("Invalid max_health value (has to be > 0), input value", value)
			return
		if value < health:
			health = value
			max_health = value
		else:
			max_health = value

var vulnerable: bool = true

signal health_change
@export var health: int = 10:
	set(value):
		if (value > health):
			health = min(value, max_health)
		else:
			if vulnerable:
				health = max(value, 0)
				vulnerable = false
				hit_timer(0.2)
		health_change.emit(health, max_health)
		print(OwnerEntity, " Health after change: ", health)

func damage(attack: AttackObj) -> void:
	health -= attack.damage
	if (health == 0):
		print(OwnerEntity, 'out of health')
		OwnerEntity.modulate = "ff0000"
		OwnerEntity.set_physics_process(false)
		OwnerEntity.queue_free()
	if OwnerEntity.has_method("knockback"):
		OwnerEntity.knockback(attack)
		pass

func hit_timer(sec: float) -> void:
	await get_tree().create_timer(sec).timeout
	vulnerable = true
