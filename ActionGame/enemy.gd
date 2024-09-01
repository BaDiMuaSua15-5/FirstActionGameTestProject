extends CharacterBody2D
class_name EnemyObj

@export var player: PlayerObj
var target_pos: Vector2
var origin_pos: Vector2
var origin_rotation_vector: Vector2

@export var max_speed: int = 450
@export var speed: float
@export var speed_mult: float = 1
var movement_acceleration: float = 450
var start_strafe_distance: float = 400

@export var health: int = 100
@export var MAX_HEALTH: int = 100

var rotation_speed: float = 2.25
@export var max_rotation_speed: float = 2.25
var is_dead: bool = false
var in_knockback: bool = false
var in_atk_push: bool = false
var in_combat: bool = false

var atk_push_time: float = MAX_PUSH_TIME
const MAX_PUSH_TIME: float = 0.37

@onready var HealthComponent: PlayerHealthComponent = %HealthComponent 
@onready var HitBox: HitBoxComponent = %HitBoxComponent
@onready var FSM: FiniteStateMachine = %FiniteStateMachine
@onready var wallRay: RayCast2D = %WallDetectRay
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D
@onready var NavTimer: Timer = $NavTimer
@onready var StunTimer: Timer = %StunTimer
@onready var StateLabel: Label = %debug
@onready var HealthBar: ProgressBar = $HealthBar
@onready var ContextRays: Node2D = $ContextRays

# Context Behaviors

@export var look_ahead: float = 300.0 + 130.0
@export var num_rays: int = 8
var ray_directions: Array[Vector2] = []
var interest: Array[float] = []
var danger: Array[float] = []
var chosen_dir: Vector2 = Vector2.ZERO
const CONTEXT_RAY_DETECT_MASK := 0b1111

func _ready() -> void:
	set_context_rays()
	
	HealthComponent.max_health = MAX_HEALTH
	HealthComponent.health = health
	
	%WeaponComponent.connect("attack_finished", _on_weapons_component_attack_finished)
	%WeaponComponent.connect("attack_started", _on_weapons_component_attack_signal)
	HealthComponent.connect("health_change", _on_health_change)
	call_deferred("_on_health_change", HealthComponent.health, HealthComponent.max_health)
	
	rotation_speed = max_rotation_speed
	speed = max_speed
	start_strafe_distance = randi_range(200, 400)
	origin_pos = global_position
	origin_rotation_vector = Vector2.UP.rotated(global_rotation)
	target_pos = origin_pos

func _process(delta: float) -> void:
	if (atk_push_time > 0.0):
		atk_push_time -= delta
	else:
		in_atk_push = false
	
	wallRay.position = position
	HealthBar.position = position + Vector2(-128, -152)
	StateLabel.position = position + Vector2(-50, 0)

func set_context_rays() -> void:
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle: float = i * 2.0 * PI / num_rays
		var r := RayCast2D.new()
		r.target_position = Vector2.UP.rotated(angle) * look_ahead
		r.enabled = true
		r.collision_mask = CONTEXT_RAY_DETECT_MASK
		r.add_exception(self)
		ContextRays.add_child(r)
		ray_directions[i] = Vector2.UP.rotated(angle)
	
	
func _draw() -> void:
	if ray_directions.is_empty() || interest.is_empty():
		return
	for i in num_rays:
		draw_line(Vector2(), (ray_directions[i] * look_ahead * interest[i]), Color.CHARTREUSE, 3.0)
	
	draw_line(Vector2(), chosen_dir * max_speed, Color.DEEP_PINK, 3.0)

func set_interest() -> void:
	wallRay.target_position = target_pos - global_position
	
	# Set interest in each slot based on world direction
	interest.resize(num_rays)
	# If there is any obstacle to target_pos Navigate with Agent
	if !navAgent.is_navigation_finished() && wallRay.is_colliding():
		var next_position := navAgent.get_next_path_position() - global_position
		var path_direction: Vector2 = next_position
		for i in num_rays:
			var d := ray_directions[i].rotated(rotation).dot(path_direction.normalized())
			interest[i] = max(0, d)
	# If no obstruction go straight for target
	elif (target_pos - global_position).length() > 0.0:
		var next_position := target_pos - global_position
		var path_direction: Vector2 = next_position
		# Movement in Combat
		if player && in_combat:
			var distance_to_player := (player.global_position - global_position).length()
			# Strafe arounf player
			if distance_to_player <= start_strafe_distance + 150 && distance_to_player >= start_strafe_distance:
				var stafe_direction := Vector2(path_direction.y, -path_direction.x)
				stafe_direction = stafe_direction if randi_range(0, 1) == 1 else -stafe_direction
				path_direction = stafe_direction
			# If player is too close move away
			elif distance_to_player < start_strafe_distance:
				print("Too close")
				path_direction = -path_direction
		for i in num_rays:
			var d := ray_directions[i].rotated(rotation).dot(path_direction.normalized())
			interest[i] = max(0, d)
	# If no world path, use default interest
	else:
		interest.clear()
		return

func set_default_interest() -> void:
	# Default to moving forward
	for i in num_rays:
		var d := ray_directions[i].rotated(rotation).dot(-transform.y)
		interest[i] = max(0, d)

func set_danger() -> void:
	# Cast rays to find danger directions
	for i in num_rays:
		var ray := ContextRays.get_child(i) as RayCast2D
		# set strenght of danger based on distance
		if ray.is_colliding():
			var collider := ray.get_collider()
			var collide_position := ray.get_collision_point()
			var distance_ratio := ((collide_position - global_position).length()) / (look_ahead) # 130 to account for enemy radius
			danger[i] = min(0.6 ,1.0 - distance_ratio) * 2
		else:
			danger[i] = 0.0
		
func choose_direction() -> void:
	chosen_dir = Vector2.ZERO
	if interest.is_empty():
		return
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] -= danger[i]
	# Choose direction based on remaining interest
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
	queue_redraw()

var knockback_dir: Vector2
var atk_push_dir: Vector2
func _physics_process(delta: float) -> void:
	if (in_knockback):
		#print("Is knockback")
		velocity = knockback_dir * 7.0
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if (in_atk_push):
		#print("Is attack push")
		velocity = atk_push_dir * 750.0
		atk_push_dir = atk_push_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if is_dead:
		apply_friction(max_speed * delta * 5)
		move_and_slide()
		return
	
	wallRay.target_position = target_pos
	set_interest()
	set_danger()
	choose_direction()
	
	var desired_velocity: Vector2
	desired_velocity = chosen_dir.rotated(rotation) * max_speed
	if int(desired_velocity.length()) == 0:
		rotate_to(global_position + origin_rotation_vector * 100, delta)
		velocity = Vector2.ZERO
	else:
		var distance_to_target := (target_pos - global_position).length()
		desired_velocity = desired_velocity * speed_mult
		if distance_to_target / delta > max_speed:
			accelerate(movement_acceleration * delta, desired_velocity)
		else:
			var max := distance_to_target / delta
			var dir :Vector2= desired_velocity.normalized() * max * speed_mult
			velocity = dir
		rotate_to(target_pos, delta)
	move_and_slide()
	queue_redraw()
	return
	
#END _physics_processDS

func accelerate(acceleration: float, target_velocity: Vector2) -> void:
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration)
	velocity.y = move_toward(velocity.y, target_velocity.y, acceleration)

func apply_friction(amount: float) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO
   
func rotate_to(target: Vector2, delta: float) -> void:
	var direction := (target - global_position).normalized()
	var angleTo: float = (-transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))

func hitted(attack: AttackObj) -> void:
	if is_dead:
		print(self, ", Is dead")
		return
	if HealthComponent.health == 0:
		is_dead = true
	#====Knockback fix======
	# Set knockback direction and status to start
	# moving object towards the knockback direction
	# (executed in physics_process)
	knockback_dir = attack.direction * attack.knockback
	in_knockback = true
	if attack.Attacker is PlayerObj:
		player = attack.Attacker
	#=======================
	
	
	StunTimer.wait_time = attack.stun_time
	FSM.change_state("Stun")

func _on_death() -> void:
	set_physics_process(false)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.6)
	await tween.finished
	queue_free()

func high_velocity_collide(attack: AttackObj) -> void:
	print(self, ": collided high velocity")
	HitBox.hit(attack)

func _on_weapons_component_attack_signal() -> void:
	speed_mult = 0
	rotation_speed = 1
	atk_push_dir = (%FacingNode.global_position - global_position).normalized()
	in_atk_push = true
	atk_push_time = MAX_PUSH_TIME
	
func _on_weapons_component_attack_finished() -> void:
	speed_mult = 1
	rotation_speed = max_rotation_speed

func _on_nav_timer_timeout() -> void:
	navAgent.target_position = target_pos

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	
func _on_health_change(health: int, max_health: int) -> void:
	HealthBar.max_value = max_health
	HealthBar.value = health
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
