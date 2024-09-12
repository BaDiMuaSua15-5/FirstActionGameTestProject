extends BaseAttackUpgrade
class_name AttackDamageUpgrade

@export var damge: float = 0.1
@export var knock_back_mult: float = 0


func apply_upgrade(attack: AttackObj) -> void:
	attack.damage += damge * tier
	attack.knockback += knock_back_mult * attack.knockback * tier
 
