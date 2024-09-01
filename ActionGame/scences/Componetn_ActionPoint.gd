extends Node
class_name APComponent

var max_progress: int = 100
var fill_progress: int = 0

signal ap_change

@export var ap_count_max: int = 5
@export var ap_count: int = 0:
	set(value):
		if value > ap_count:
			ap_count = min(value, ap_count_max)
		else:
			ap_count = max(0, value)

func accumulate(amount: int) -> void:
	if ap_count == ap_count_max:
		return
	fill_progress += amount
	if fill_progress >= max_progress:
		if ap_count < ap_count_max - 1:
			var overflow: int = fill_progress - max_progress
			fill_progress = overflow
		else:
			fill_progress = 0
		ap_count = ap_count + 1
	
	ap_change.emit(fill_progress, ap_count)

func spend_point(amount: int) -> bool:
	if amount > ap_count:
		return false
	
	ap_count -= 1
	ap_change.emit(fill_progress, ap_count)
	return true

