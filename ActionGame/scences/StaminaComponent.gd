extends Node
class_name StaminaComponent

@export var max_stamina = 25
signal stamina_change

@export var stamina: float = 10.0:
	set(value):
		if (value > stamina):
			stamina = min(value, max_stamina)
		else:
			stamina = max(value, 0)
		stamina_change.emit(stamina, max_stamina)
