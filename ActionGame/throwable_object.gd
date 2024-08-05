extends CharacterBody2D
class_name Throwable

var draggable: bool = false
var offset: Vector2
var prev_pos: Vector2
var prev_velocity

var elapsed_time: float
var start_move_time: float
var pos_save_time: float

@export var Group: String

var collision: KinematicCollision2D
func _physics_process(delta):
	elapsed_time += delta
	if draggable:
		if Input.is_action_pressed("mouse_click") && Global.is_dragging:
			print(velocity)
			#velocity = ((get_global_mouse_position() - offset) - global_position) * 10
			var direction = get_global_mouse_position() - global_position
			velocity = direction.normalized() * 500
			move_and_slide()
			# The larger the timeframe between checks for position
			# The further the object can be dragged in that timeframe 
			# -> More "Sling shot" like behavior
			if elapsed_time - pos_save_time >= 0.1: 
				if (global_position - prev_pos).length_squared() > 50 * 50:
					prev_pos = global_position
				pos_save_time = elapsed_time
		
	else:
		prev_velocity = velocity
		
		collision = move_and_collide(velocity * delta)
		
		if collision:
			var collider: PhysicsBody2D = collision.get_collider()
			print("Normal: x = ", collision.get_normal().x, ", y = ", collision.get_normal().y)
			print("Velocity before: ", velocity)
			var reflected_velocity = velocity.bounce(collision.get_normal())
			print("Velocity after: ", reflected_velocity)
			velocity = reflected_velocity
			
		velocity = velocity.lerp(Vector2.ZERO, delta * 3)
		
		
func _input(event):
	if !draggable:
		return
	
	if event.is_action_released("mouse_click"):
		print("Release")
		Global.is_dragging = false
		draggable = false
		visual_feedback()
		if elapsed_time - start_move_time < 0.1:
			velocity = (global_position - prev_pos) * 10
		else:
			velocity = Vector2.ZERO
		
	if event is InputEventMouseMotion:
		start_move_time = elapsed_time


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_click"):
		if is_on_top():
			print("Click")
			draggable = true
			prev_pos = global_position
			Global.is_dragging = true
			offset = event.global_position - global_position
			visual_feedback()

func is_on_top() -> bool:
	print(get_tree().get_nodes_in_group(Group + "hovered"))
	for draggable in get_tree().get_nodes_in_group(Group + "hovered"):
		if draggable.get_index() > get_index():
			return false
			
	return true
	
func visual_feedback() -> void:
	if draggable:
		get_child(0).scale = Vector2(1.05, 1.05)
		modulate = Color("fcfc00")
	else:
		get_child(0).scale = Vector2(1, 1)
		modulate = Color(1, 1, 1)

func _on_mouse_entered():
	add_to_group(Group + "hovered")
	#Global.throwable_ref = self
	#if !Global.is_dragging:
		#draggable = true
		#scale = Vector2(1.05, 1.05)

func _on_mouse_exited():
	remove_from_group(Group + "hovered")
	#if !Global.is_dragging:
		#draggable = false
		#scale = Vector2(1, 1)
	


