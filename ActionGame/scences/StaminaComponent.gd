extends Node
class_name StaminaComponent

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
