extends Area2D
class_name HitBoxComponent

@export var HealthComp: PlayerHealthComponent
@onready var OwnerEntity: Node2D = self.owner

func hit(attack: AttackObj) -> void:
	#print(owner, ' hitted hitbox')
	
	var health_before := HealthComp.health
	HealthComp.damage(attack)
	if health_before > HealthComp.health:
		OwnerEntity.hitted(attack)
	
