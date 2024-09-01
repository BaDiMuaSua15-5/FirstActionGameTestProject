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

@export var WeaponResource: Weapon_Resource
var attack_object: AttackObj # Attack object to damage collider in high speed collision

@export var Group: String
@onready var original_collision_layer := 0b0100
@onready var original_collision_mask := 0b0111
var original_avoidance_layer: int 

@onready var Pariticle: GPUParticles2D = $GPUParticles2D
@export var Sprite: Sprite2D
@export var NavObstacle: NavigationObstacle2D
@onready var origin_scale := Sprite.scale

var in_range_objects: Array

func _ready() -> void:
	original_avoidance_layer = NavObstacle.avoidance_layers
	
	attack_object = AttackObj.new()
	attack_object.damage = WeaponResource.Damage
	attack_object.knockback = WeaponResource.knockback
	attack_object.stun_time = WeaponResource.stun_time
	attack_object.direction = Vector2.ZERO
	attack_object.Attacker = self

#var collision: KinematicCollision2D
func _physics_process(delta: float) -> void:
	
	elapsed_time += delta
	if draggable: # When being dragged
		if Input.is_action_pressed("mouse_pickup") && Global.is_dragging:
			queue_redraw()
			var collision := move_and_collide(velocity)
			var direction := get_global_mouse_position() - offset - global_position
			velocity = process_collision(collision, direction, delta)
			prev_velocity = velocity
			
	else:
		if (velocity.length() <= 350):
			can_bounce = false
		else:
			can_bounce = true
		velocity = velocity.normalized() * min(6000.0, velocity.length())
		queue_redraw()
		var collision := move_and_collide(velocity * delta)
		velocity = process_collision(collision, velocity, delta)
		
		prev_velocity = velocity
		apply_friction(delta * 1400 * 2)
	return

func process_collision(collision: KinematicCollision2D, dir_to_mouse: Vector2, delta: float) -> Vector2:
	if collision == null || collision.get_collider() == null:
		return dir_to_mouse
	var collider: PhysicsBody2D = collision.get_collider() as PhysicsBody2D
	var remainder := collision.get_remainder()
	
	# Slide movement
	if !draggable: 
		# ======= Damage feature =======
		if (velocity.length() > 1800.0 && collider):
			if collider.has_method("high_velocity_collide"):
				collider.high_velocity_collide(attack_object)
				hit_nearby(attack_object)
				Sprite.visible = false 
				Pariticle.emitting = true
				$FreeTimer.start(2.0)
				Global.play_throw_break_sound()
			else:
				Global.play_throw_collide_sound()
		elif velocity.length() >= 350:
			Global.play_throw_collide_sound()
		# ===============================
		
		# Calculate reflected bounce direction
		var normal:= collision.get_normal()
		var bounce_dir := dir_to_mouse.bounce(normal)
		if can_bounce:
			if (collider is CharacterBody2D):
				var push_dir := -normal
				(collider as CharacterBody2D).velocity = push_dir * dir_to_mouse.length() * 0.25
			return bounce_dir * 0.25
		else:
			var angle_to_normal := rad_to_deg(dir_to_mouse.normalized().angle_to(normal))
			angle_to_normal = absf(angle_to_normal)
			if collider is CharacterBody2D:
				print("Collide throw, angle: ", angle_to_normal)
				if angle_to_normal > 90:
					var push_dir := -normal * dir_to_mouse.length()
					(collider as CharacterBody2D).velocity = push_dir
					return (bounce_dir.normalized()) * dir_to_mouse.length()
					
				else:
					print(self, " - VELOCITY: ", dir_to_mouse)
					print(self, " Coliider vel: ",(collider as CharacterBody2D).velocity, " ", collider)
					print("Normal: ", normal)
					return -normal * (collider as CharacterBody2D).velocity.length()
				
			
			print("Collide wall")
			print(self, " - VELOCITY: ", dir_to_mouse)
			print("Normal: ", normal)
			var reflect_dir := dir_to_mouse - normal * dir_to_mouse.dot(normal)
			move_and_collide(reflect_dir.normalized() * dir_to_mouse.length() * delta)
			return reflect_dir.normalized() * dir_to_mouse.length()
	# Drag movement
	else: # Slide around object when dragged around static objects
		if collider && (collider.is_in_group("throwable")): # If collided with a movable object
			# Mimic pushing behavior
			
			var normal:= collision.get_normal().normalized()
			var velocity_clamp: float= clamp(dir_to_mouse.length(), 0, 300)
			var drag_velocity: Vector2 = dir_to_mouse.normalized() * velocity_clamp
			
			collider = collider as CharacterBody2D
			collider.velocity = -normal * velocity_clamp
			#collider.set_deferred("velocity", -normal * velocity_clamp)
			
			return drag_velocity
			
		else : # If collided with a static object
			var normal:= collision.get_normal()
			var direction := dir_to_mouse.normalized()
			direction_vec = direction - normal * direction.dot(normal)
			var deflected_dir := direction - normal * direction.dot(normal)
			return deflected_dir * dir_to_mouse.length()
			

# ==========================================================================
		
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
			velocity = prev_velocity * 60
		else:
			velocity = Vector2.ZERO
		
	if event is InputEventMouseMotion:
		start_move_time = elapsed_time
		#prev_pos = global_position
		

var direction_vec: Vector2
var test_deflect: Vector2
func _draw() -> void:
	draw_line(Vector2(), velocity, Color.BLUE, 4)


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
			#var player := Global.player as PlayerObj
			#var result := player.APComp.spend_point(1)
			#if result == false:
				#return
				
			print("Click")
			draggable = true
			visual_feedback()
			offset = get_global_mouse_position() - global_position
			prev_velocity = Vector2.ZERO
			prev_pos = global_position
			Global.is_dragging = true
			
			collision_layer = 0b0000
			NavObstacle.avoidance_layers = 0b0
	return

func _on_mouse_entered() -> void:
	add_to_group(Group + "hovered")

func _on_mouse_exited() -> void:
	remove_from_group(Group + "hovered")

func _on_gpu_particles_2d_finished() -> void:
	queue_free()

func _on_free_timer_timeout() -> void:
	queue_free()


func _on_explode_area_area_entered(area: Area2D) -> void:
	area = area as HitBoxComponent
	if area:
		in_range_objects.append(area)


func _on_explode_area_area_exited(area: Area2D) -> void:
	area = area as HitBoxComponent
	if area:
		in_range_objects.erase(area)

func hit_nearby(attack: AttackObj) -> void:
	attack.damage = 20
	for hitbox: HitBoxComponent in in_range_objects:
		var knockback_dir := hitbox.global_position - global_position
		attack.direction = knockback_dir.normalized()
		hitbox.hit(attack)
