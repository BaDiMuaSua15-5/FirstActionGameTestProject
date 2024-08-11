extends Area2D
class_name HitBoxComponent

@export var HealthComponent: PlayerHealthComponent

func hit(attack: AttackObj) -> void:
	print('hitted hitbox')
	HealthComponent.damage(attack)
