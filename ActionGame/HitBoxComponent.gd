extends Area2D
class_name HitBoxComponent

@export var HealthComp: PlayerHealthComponent
@onready var OwnerEntity: Node = self.owner

func hit(attack: AttackObj) -> void:
	print(owner, ' hitted hitbox')
	var owner_entity := owner
	
	var health_before := HealthComp.health
	HealthComp.damage(attack)
	if health_before > HealthComp.health:
		owner_entity.hitted(attack)
	
