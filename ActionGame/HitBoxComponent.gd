extends Area2D
class_name HitBoxComponent

@export var HealthComponent: PlayerHealthComponent

func hit(attack: AttackObj) -> void:
	print(owner, ' hitted hitbox')
	Global.play_hit_sound()
	if attack.Attacker is Throwable:
		print("IS throwable")
		(Global.camera as ShakeableCamera).add_trauma(0.7)
	else:
		(Global.camera as ShakeableCamera).add_trauma(0.35)
	Global.hitstop_effect(0.5, 0.10)
	HealthComponent.damage(attack)
