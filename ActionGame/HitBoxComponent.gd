extends Area2D
class_name HitBoxComponent

@export var HealthComponent: PlayerHealthComponent

func hit(attack: AttackObj) -> void:
	print(owner, ' hitted hitbox')
	Global.hitstop_effect(0.5, 0.1)
	HealthComponent.damage(attack)
