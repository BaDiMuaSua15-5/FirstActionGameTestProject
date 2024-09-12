extends BaseUpgrade
class_name MoveSpeedUpgrade

@export var speed_mult: float = 1.25

func calculate_speed(speed: float) -> float:
	speed = speed * speed_mult
	return speed
