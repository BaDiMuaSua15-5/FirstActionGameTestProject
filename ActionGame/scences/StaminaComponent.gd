extends Node
class_name StaminaComponent

@onready var RegenTimer: Timer = $StaminaGenTimer as Timer
var can_regen: bool = true

@export var max_stamina: float = 25:
	set(value):
		if (value <= 0):
			print("Invalid max_stamina value (has to be > 0), input value", value)
			return
		max_stamina = value
			
signal stamina_change

@export var stamina: float = 10.0:
	set(value):
		if (value > stamina):
			stamina = min(value, max_stamina)
		else:
			stamina = max(0.0, value)
		stamina_change.emit(stamina, max_stamina)

func get_stamina() -> float:
	return stamina
	
func add(amount: float) -> void:
	if can_regen && amount > 0:
		stamina += amount

func deplete_stamina(deplete_amount: float, start_recover_time: float = 0.0) -> void:
	if deplete_amount <= 0.0:
		return
	stamina -= deplete_amount
	can_regen = false
	if start_recover_time > 0.0:
		delay_regen_timer(start_recover_time)
	
func delay_regen_timer(time: float) -> void:
	RegenTimer.wait_time = time
	RegenTimer.start()

func _on_stamina_gen_timer_timeout() -> void:
	can_regen = true
