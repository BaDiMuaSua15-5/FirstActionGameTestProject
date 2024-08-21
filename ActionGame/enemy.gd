extends CharacterBody2D
class_name EnemyObj

@export var player: PlayerObj
var target_pos: Vector2
var origin_pos: Vector2
var origin_rotation: float

@export var max_speed: int = 450
@export var speed: float
@export var speed_mult: float = 1
var accel: float = 8

@export var health: int = 100
@export var MAX_HEALTH: int = 100

var rotation_speed: float = 2.25
var is_dead: bool = false
var in_knockback: bool = false
var in_atk_push: bool = false

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

func _ready() -> void:
	HealthComponent.max_health = MAX_HEALTH
	HealthComponent.health = health
	
	print("Enemy health: ", health)
	
	speed = max_speed
	#HitBox.connect("hitted", damage)
	%WeaponComponent.connect("attack_finished", _on_weapons_component_attack_finished)
	%WeaponComponent.connect("attack_started", _on_weapons_component_attack_signal)
	HealthComponent.connect("health_change", _on_health_change)
	_on_health_change(HealthComponent.health, HealthComponent.max_health)
	
	
	target_pos = global_position
	origin_pos = global_position
	origin_rotation = global_rotation
	print(global_rotation)

func _process(delta: float) -> void:
	wallRay.global_rotation = 0
	if (atk_push_time > 0.0):
		atk_push_time -= delta
	else:
		in_atk_push = false
		
	HealthBar.position = position + Vector2(-128, -152)
	StateLabel.position = position + Vector2(-50, 0)

var knockback_dir: Vector2
var atk_push_dir: Vector2
func _physics_process(delta: float) -> void:
	if (in_knockback):
		print("Is knockback")
		velocity = knockback_dir * 7.0
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if (in_atk_push):
		print("Is attack push")
		velocity = atk_push_dir * 1150.0
		atk_push_dir = atk_push_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if velocity.length() == 0.0:
		print("Resting", velocity)
		rotation = origin_rotation
	
	if player != null:
		target_pos = player.global_position
	if target_pos != null:
		wallRay.target_position = (target_pos - position)
		# check if there are any obstructions between enemy
		# and target
		var direction: Vector2
		#direction = (player.global_position - global_position).normalized()
		if wallRay.get_collider() == null: # direct tracking
			navAgent.avoidance_enabled = false
			#print("Static nav")
			direction = (target_pos - global_position)
			if direction.length() < max_speed:
				velocity = direction / delta
			else:
				velocity = direction.normalized() * max_speed
				move_and_slide()
			
		else: # navigation based tracking
			navAgent.avoidance_enabled = true
			#print("dynamic nav")
			direction = (navAgent.get_next_path_position() - position).normalized()
			navAgent.velocity = direction * max_speed
		#accelerate(450 * 3 * delta, direction * max_speed)
		rotate_to(target_pos, delta)
	else:
		apply_friction(450 * 5 * delta)
		move_and_slide()
	
	
#END _physics_process

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

func knockback(attack: AttackObj) -> void:
	if is_dead:
		print(self, ", Is dead")
		return
		
	#====Knockback fix======
	# Set knockback direction and status to start
	# moving object towards the knockback direction
	# (executed in physics_process)
	knockback_dir = attack.direction * attack.knockback
	in_knockback = true
	#=======================
	#print("pos before: "+str(global_position))
	
	StunTimer.wait_time = attack.stun_time
	FSM.change_state("Stun")

func high_velocity_collide(attack: AttackObj) -> void:
	print(self, ": collided high velocity")
	HitBox.hit(attack)

func _on_weapons_component_attack_signal() -> void:
	#print('start')
	speed_mult = 0
	rotation_speed = 1
	atk_push_dir = (%FacingNode.global_position - global_position).normalized()
	in_atk_push = true
	atk_push_time = MAX_PUSH_TIME
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property(self, "global_position", global_position + attack_dir * 100, 0.10)
	
func _on_weapons_component_attack_finished() -> void:
	speed_mult = 1
	rotation_speed = 2.25



func _on_stun_timer_timeodut() -> void:
	#print("pos after: "+str(global_position))
	speed_mult = 1
	rotation_speed = 2.25
	in_knockback = false

func _on_nav_timer_timeout() -> void:
	navAgent.target_position = target_pos


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	#print("Nav velocity computed. ", safe_velocity.length())
	if safe_velocity.length() == 0:
		return
	velocity = safe_velocity
	move_and_slide()
	
func _on_health_change(health: int, max_health: int) -> void:
	HealthBar.max_value = max_health
	HealthBar.value = health
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
