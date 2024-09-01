extends Area2D
class_name HitBoxComponent

@export var HealthComp: PlayerHealthComponent

func hit(attack: AttackObj) -> void:
	print(owner, ' hitted hitbox')
	var owner_entity := owner
	Global.play_hit_sound()
	if Global.camera:
		# Shake camera based on attack object
		if attack.Attacker is Throwable:
			(Global.camera as ShakeableCamera).add_trauma(0.7)
		else:
			(Global.camera as ShakeableCamera).add_trauma(0.35)
			# Player accumulate AP when hit enemy
			if attack.Attacker is PlayerObj:
				var player := attack.Attacker as PlayerObj
				player.APComp.accumulate(attack.ap_accumulation)
	Global.hitstop_effect(0.5, 0.10)
	HealthComp.damage(attack)
	# Disable hitbox when health <= 0
	if HealthComp.health <= 0:
		var collision_poly := get_child(0) as CollisionPolygon2D
		collision_poly.set_deferred("disabled", true)
	owner_entity.hitted(attack)
	
