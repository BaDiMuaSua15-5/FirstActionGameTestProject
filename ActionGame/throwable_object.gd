extends CharacterBody2D
class_name Throwable

var draggable: bool = false
var offset: Vector2
var prev_pos: Vector2
var prev_velocity: Vector2
@export var velocity_damage: int = 10

var elapsed_time: float
var start_move_time: float
var pos_save_time: float

@export var Group: String
@export var original_collision_layer := collision_layer
@export var original_collision_mask := collision_mask

var collision: KinematicCollision2D
func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if draggable: # When being dragged
		if Input.is_action_pressed("mouse_pickup") && Global.is_dragging:
			var direction := get_global_mouse_position() - offset - global_position
			var processed_direction := process_collision(collision, direction / delta)
			velocity = process_collision(collision, direction / delta)
			#velocity = direction / delta
			collision = move_and_collide(velocity * delta)
				
			prev_velocity = global_position - prev_pos
		
	else:
		velocity = velocity.clamp(Vector2(-3000, -3000), Vector2(3000, 3000))
		collision = move_and_collide(velocity * delta)
		
		if collision:
			velocity = process_collision(collision, Vector2.ZERO)
			
		velocity = velocity.lerp(Vector2.ZERO, delta * 3)
		
		
func _input(event: InputEvent) -> void:
	if !draggable:
		return
	
	if event.is_action_released("mouse_pickup"):
		print("Release")
		Global.is_dragging = false
		draggable = false
		visual_feedback()
		#collision_layer = original_collision_layer
		if elapsed_time - start_move_time < 0.1:
			prev_velocity = (prev_velocity * 60).clamp(Vector2(-3000, -3000), Vector2(3000, 3000))
			#print("Velocity: ", prev_velocity)
			velocity = prev_velocity
		else:
			velocity = Vector2.ZERO
		
	if event is InputEventMouseMotion:
		start_move_time = elapsed_time
		prev_pos = global_position
		

var direction_vec: Vector2
func _draw() -> void:
	draw_line(Vector2(), direction_vec, Color.BLUE, 4)
		
func process_collision(collision: KinematicCollision2D, dir_to_mouse: Vector2) -> Vector2:
	if collision == null:
		return dir_to_mouse
	var collider: PhysicsBody2D = collision.get_collider()
	var remainder := collision.get_remainder()
	
	if !draggable: # Bounce behavior
		# ======= Damage feature =======
		#print("Colided velocity:", velocity.length())
		#var damage: AttackObj
		#if (velocity.length() > 1800.0):
			
		
		# ===============================
		
		# Push the collied object away
		if (collider is CharacterBody2D): # If collided with a movable object
			print(collider)
			(collider as CharacterBody2D).velocity += collision.get_remainder() * 30
		# Calculate reflected bounce direction
		var reflected_velocity := remainder.bounce(collision.get_normal())
		return reflected_velocity * 60 # Times 60 for more forceful bounce
		
	else: # Slide around object when dragged around static objects
		if (collider.is_in_group("throwable")): # If collided with a movable object
			# Mimic pushing behavior
			if !(collider is PlayerObj):
				(collider as CharacterBody2D).velocity += remainder
			var normal:= collision.get_normal()
			var direction := velocity
			var length := remainder.length()
			direction_vec = direction - normal * direction.dot(normal)
			queue_redraw()
			return (remainder.normalized() + direction_vec.normalized()) * (length - 2)
			
		else : # If collided with a static object
			var normal:= collision.get_normal()
			var direction := velocity
			direction_vec = direction - normal * direction.dot(normal)
			queue_redraw()
			return direction - normal * direction.dot(normal)
	

func visual_feedback() -> void:
	if draggable:
		get_child(0).scale = Vector2(1.05, 1.05)
		modulate = Color("fcfc00")
	else:
		get_child(0).scale = Vector2(1, 1)
		modulate = Color(1, 1, 1)


func is_on_top() -> bool:
	#print(get_tree().get_nodes_in_group(Group + "hovered"))
	for draggable in get_tree().get_nodes_in_group(Group + "hovered"):
		if draggable.get_index() > get_index():
			return false
			
	return true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouse_pickup"):
		if is_on_top():
			print("Click")
			draggable = true
			prev_velocity = Vector2.ZERO
			prev_pos = global_position
			Global.is_dragging = true
			offset = get_global_mouse_position() - global_position
			visual_feedback()
			#collision_layer = 0


func _on_mouse_entered() -> void:
	add_to_group(Group + "hovered")
	#Global.throwable_ref = self
	#if !Global.is_dragging:
		#draggable = true
		#scale = Vector2(1.05, 1.05)


func _on_mouse_exited() -> void:
	remove_from_group(Group + "hovered")
	#if !Global.is_dragging:
		#draggable = false
		#scale = Vector2(1, 1)
	



