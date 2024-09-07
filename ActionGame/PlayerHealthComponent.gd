extends Node
class_name PlayerHealthComponent

@onready var HitTimer: Timer = $HitTimer
@onready var OwnerEntity: CollisionObject2D = self.owner

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
		health_change.emit(health, max_health)
		print(OwnerEntity, " Health after change: ", health)

func damage(attack: AttackObj) -> void:
	var health_before := health
	health -= attack.damage
	hit_timer(0.2)
	vulnerable = false
	if (health == 0):
		OwnerEntity._on_death()
	return

func hit_timer(sec: float) -> void:
	await get_tree().create_timer(sec).timeout
	vulnerable = true
