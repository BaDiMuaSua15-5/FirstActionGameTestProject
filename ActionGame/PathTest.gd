extends Path2D

@onready var path: Path2D = $"."
@onready var path_follow: PathFollow2D = $PathFollow2D
@export var marker: Node2D
var click_pos: Vector2 = Vector2()

func get_path_direction(pos: Vector2) -> Vector2:
	var offset := path.curve.get_closest_offset(pos)
	##path_follow.h_offset = path.curve.sample_baked(offset).x
	##path_follow.v_offset = path.curve.sample_baked(offset).y
	#path_follow.position = path.curve.sample_baked(offset)
	path_follow.progress = offset
	##path_follow.v_offset = offset
	return path_follow.transform.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		click_pos = event.global_position

func _physics_process(delta: float) -> void:
	marker.global_position = path_follow.global_position
