extends BaseUpgrade
class_name HealthHealUpgrade

@export var heal_amount: float = 2

func apply_upgrade_(entity: CharacterBody2D) -> void:
	if entity == null:
		return
	var heal_comp := entity.HealthComp as PlayerHealthComponent
	print("Before: " + str(heal_comp.health))
	heal_comp.health += heal_amount
	print("Healed: " + str(heal_comp.health))
	
