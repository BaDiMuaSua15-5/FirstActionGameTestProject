extends BaseAttackUpgrade
class_name AttackAccumulationUpgrade


@export var ap_accumulation_mult: float = 0.2

func apply_upgrade(attack: AttackObj) -> void:
	attack.ap_accumulation += ap_accumulation_mult * attack.ap_accumulation
