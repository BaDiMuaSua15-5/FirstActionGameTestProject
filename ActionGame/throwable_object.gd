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
var can_bounce: float = false


var damage: int
@export var WeaponResource: Weapon_Resource
var attack_object: AttackObj # Attack object to damage collider in high speed collision

@export var Group: String
@onready var original_collision_layer := collision_layer
@onready var original_collision_mask := collision_mask
var original_avoidance_layer: int 

@onready var Pariticle: GPUParticles2D = $GPUParticles2D
@export var Sprite: Sprite2D
@export var NavObstacle: NavigationObstacle2D
@onready var origin_scale := Sprite.scale

func _ready() -> void:
	original_avoidance_layer = NavObstacle.avoidance_layers

#var collision: KinematicCollision2D
func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if draggable: # When being dragged
		if Input.is_action_pressed("mouse_pickup") && Global.is_dragging:
			
			var collision := move_and_collide(velocity)
			prev_velocity = velocity
			
			var direction := get_global_mouse_position() - offset - global_position
			velocity = process_collision(collision, direction, delta)
			
			
			
	else:
		if (velocity.length() < 100):
			can_bounce = false
		else:
			can_bounce = true
		velocity = velocity.normalized() * min(6000.0, velocity.length())
		var collision := move_and_collide(velocity * delta)
		velocity = process_collision(collision, velocity, delta)
			
		prev_velocity = velocity
		apply_friction(delta * 1400 * 2)
		
		
func apply_friction(amount: float) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity -= velocity
		
func _input(event: InputEvent) -> void:
	if !draggable:
		return
	
	if event.is_action_released("mouse_pickup"):
		print("Release")
		Global.is_dragging = false
		draggable = false
		can_bounce = true
		visual_feedback()
		collision_layer = original_collision_layer
		collision_mask = original_collision_mask
		NavObstacle.avoidance_layers = original_avoidance_layer
		if elapsed_time - start_move_time < 0.1:
			velocity = prev_velocity.normalized() * min(6000.0, prev_velocity.length() * 60)
		else:
			velocity = Vector2.ZERO
		
	if event is InputEventMouseMotion:
		start_move_time = elapsed_time
		#prev_pos = global_position
		

var direction_vec: Vector2
func _draw() -> void:
	draw_line(Vector2(), direction_vec * 60, Color.BLUE, 4)
		
func process_collision(collision: KinematicCollision2D, dir_to_mouse: Vector2, delta: float) -> Vector2:
	if collision == null || collision.get_collider() == null:
		return dir_to_mouse
	var collider: PhysicsBody2D = collision.get_collider()
	var remainder := collision.get_remainder()
	
	if !draggable: # Bounce behavior
		# ======= Damage feature =======
		#print("Colided velocity:", velocity)
		var damage: AttackObj
		if (velocity.length() > 1800.0 && collider.has_method("high_velocity_collide")):
			
			var attack: AttackObj = AttackObj.new()
			attack.damage = WeaponResource.Damage
			attack.knockback = WeaponResource.knockback
			attack.stun_time = WeaponResource.stun_time
			attack.direction = velocity.normalized()
			collider.high_velocity_collide(attack)
			Sprite.visible = false 
			Pariticle.emitting = true
		# ===============================
		
		# Push the collied object away
		if (collider is CharacterBody2D): # If collided with a movable object
			#print("collided with: ", collider)
			(collider as CharacterBody2D).velocity = velocity * 0.5
		# Calculate reflected bounce direction
		var reflected_velocity := dir_to_mouse.bounce(collision.get_normal())
		#print("Remainder length: ", remainder.length())
		#print("Bounce: ", reflected_velocity)
		if can_bounce:
			return reflected_velocity.normalized() * velocity.length() * 0.25# Times 30 for a more forceful bounce
		else:
			return velocity
		
	else: # Slide around object when dragged around static objects
		if (collider.is_in_group("throwable")): # If collided with a movable object
			# Mimic pushing behavior
			
			var normal:= collision.get_normal()
			var deflected_vec := dir_to_mouse - normal * dir_to_mouse.dot(normal)
			print("push angle: ", rad_to_deg(velocity.angle_to(normal)))
			if !(rad_to_deg(velocity.angle_to(normal)) <= 150.0 && rad_to_deg(velocity.angle_to(normal)) >= -150.0):
				(collider as CharacterBody2D).velocity = (velocity + collider.velocity)
				#collider.move_and_slide()
				return velocity * 0.2
			else:
				#(collider as CharacterBody2D).velocity = (velocity + collider.velocity)
				direction_vec = deflected_vec
				return dir_to_mouse - normal * dir_to_mouse.dot(normal)
			queue_redraw()
			#return (remainder.normalized() + direction_vec.normalized())
			#return velocity + deflected_vec.normalized() * length * 0.3
			
		else : # If collided with a static object
			var normal:= collision.get_normal()
			var direction := dir_to_mouse.normalized()
			direction_vec = direction - normal * direction.dot(normal)
			queue_redraw()
			return (direction - normal * direction.dot(normal)) * velocity.length()
	

func visual_feedback() -> void:
	if draggable:
		get_child(0).scale = Vector2(origin_scale.x + 0.05, origin_scale.y + 0.05)
		modulate = Color("fcfc00")
	else:
		get_child(0).scale = Vector2(origin_scale.x, origin_scale.y)
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
			collision_layer = 0
			collision_mask = 3
			NavObstacle.avoidance_layers = 0


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
	





func _on_gpu_particles_2d_finished() -> void:
	queue_free()
