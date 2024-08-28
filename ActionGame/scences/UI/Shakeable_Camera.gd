extends Node2D
class_name ShakeableCamera

var max_x_offset: int = 200
var max_y_offset: int = 200

@export var parent: Node2D

@export var noise :FastNoiseLite
@export var noise_speed: float = 50.0 * 2 

@export var trauma_reduction_rate := 1.0
var trauma: float = 0.0

var time: float = 0.0

@export var zoom: float = 1.0

@onready var Camera: Camera2D= $Camera2D as Camera2D
@onready var original_offset := Camera.offset as Vector2

func _ready() -> void:
	Camera.zoom = Vector2(1, 1) * zoom

func _process(delta: float) -> void:
	#follow_parent()
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	Camera.offset.x = original_offset.x + max_x_offset * get_shake_intensity() * get_noise_from_seed(0)
	Camera.offset.y = original_offset.y + max_y_offset * get_shake_intensity() * get_noise_from_seed(1)

func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
	
func get_shake_intensity() -> float:
	return trauma * trauma
	
func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)

func follow_parent() -> void:
	if parent:
		Camera.global_position = parent.global_position

func  _input(event: InputEvent) -> void:
	#if event.is_action_pressed("dodge"):
		#print("add")
		#add_trauma(0.7)
	return
