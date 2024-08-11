extends Node2D

var draggable: float = false
var is_inside_dropable: float = false
var body_ref: StaticBody2D
var offset: Vector2
var init_pos: Vector2

func _ready() -> void:
	init_pos = global_position

func _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("mouse_click"):
			print("Click")
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
		if Input.is_action_pressed("mouse_click") && Global.is_dragging:
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("mouse_click"):
			print("Release")
			Global.is_dragging = false
			var tween := get_tree().create_tween()
			if is_inside_dropable:
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				init_pos = body_ref.position
			else:
				tween.tween_property(self, "position", init_pos, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_body_entered(body: PhysicsBody2D) -> void:
	if body is StaticBody2D && body.is_in_group("dropable") && !body.occupied:
		is_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body
		body.occupied = true
		print("Occupy body")

func _on_area_2d_body_exited(body: PhysicsBody2D) -> void:
	if body is StaticBody2D && body.is_in_group("dropable") && body == body_ref:
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
		body.occupied = false


func _on_area_2d_mouse_entered() -> void:
	print("++Enter+++")
	print("Is dragging, ", Global.is_dragging)
	if !Global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	print("+++Exit+++")
	print("Is dragging, ", Global.is_dragging)
	if !Global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)
