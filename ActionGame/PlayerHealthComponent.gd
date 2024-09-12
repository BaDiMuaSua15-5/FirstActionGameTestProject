extends Node
class_name PlayerHealthComponent

@onready var HitTimer: Timer = $HitTimer
@onready var OwnerEntity: CollisionObject2D = self.owner
@export var Upgrades: UpgradesComponent

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
	get:
		var value := max_health
		if Upgrades:
			value = Upgrades.apply_health_upgrade(value)
		return value

var vulnerable: bool = true

signal health_change
signal health_depleted
@export var health: int = 10:
	set(value):
		if (value > health):
			health = min(value, max_health)
		else:
			if vulnerable:
				health = max(value, 0)
		health_change.emit(health, max_health)
		#print(OwnerEntity, " Health after change: ", health)


func damage(attack: AttackObj) -> void:
	var health_before := health
	health -= attack.damage
	hit_timer(0.2)
	vulnerable = false
	if (health == 0):
		health_depleted.emit()
	return


func hit_timer(sec: float) -> void:
	await get_tree().create_timer(sec).timeout
	vulnerable = true


func get_final_health_value(health: int) -> int:
	if Upgrades == null:
		return health
		
	else:
		return 0
