extends Area2D
class_name HitBoxComponent

@export var HealthComp: PlayerHealthComponent
@onready var OwnerEntity: Node = self.owner

func hit(attack: AttackObj) -> void:
	print(owner, ' hitted hitbox')
	var owner_entity := owner
	
	HealthComp.damage(attack)
	# Disable hitbox when health <= 0
	if HealthComp.health <= 0:
		var collision_poly := get_child(0)
		collision_poly.set_deferred("disabled", true)
	owner_entity.hitted(attack)
	
