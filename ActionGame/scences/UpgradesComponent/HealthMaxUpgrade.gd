extends BaseUpgrade
class_name HealthMaxUpgrade

@export var health_bonus: float = 0.2


func apply_upgrade_(max_health_amount: float) -> float:
	max_health_amount += max_health_amount * health_bonus
	return max_health_amount
