extends CharacterBody2D
class_name EnemyObj

@export var player: PlayerObj

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

func _ready() -> void:
	HealthComponent.max_health = MAX_HEALTH
	HealthComponent.health = health
	
	print("Enemy health: ", health)
	
	speed = max_speed
	#HitBox.connect("hitted", damage)
	%WeaponComponent.connect("attack_finished", _on_weapons_component_attack_finished)
	%WeaponComponent.connect("attack_started", _on_weapons_component_attack_signal)
	

func _process(delta: float) -> void:
	wallRay.global_rotation = 0
	if (atk_push_time > 0.0):
		atk_push_time -= delta
	else:
		in_atk_push = false
		atk_push_time = MAX_PUSH_TIME

var knockback_dir: Vector2
var atk_push_dir: Vector2
func _physics_process(delta: float) -> void:
	if (in_knockback):
		velocity = knockback_dir * 7.0
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if (in_atk_push):
		print(atk_push_dir)
		velocity = atk_push_dir * 1150.0
		move_and_slide()
		return
	
	
	if player != null:
		wallRay.target_position = (player.global_position - global_position)
		# check if there are any obstructions between enemy
		# and target
		var direction: Vector2
		#direction = (player.global_position - global_position).normalized()
		if wallRay.get_collider() == null: # direct tracking
			direction = (player.global_position - global_position).normalized()
		elif navAgent.get_next_path_position() != Vector2.ZERO: # navigation based tracking
			direction = (navAgent.get_next_path_position() - global_position).normalized()
		#velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
		accelerate(450 * 3 * delta, direction * speed)
		rotate_to(player.global_position, delta)
	else:
		apply_friction(450 * 5 * delta)
	#print(velocity)
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
	print("pos before: "+str(global_position))
	
	StunTimer.wait_time = attack.stun_time
	FSM.change_state("Stun")

func _on_weapons_component_attack_signal() -> void:
	print('start')
	speed_mult = 0
	rotation_speed = 1
	atk_push_dir = (%FacingNode.global_position - global_position).normalized()
	in_atk_push = true
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property(self, "global_position", global_position + attack_dir * 100, 0.10)
	
func _on_weapons_component_attack_finished() -> void:
	speed_mult = 1
	rotation_speed = 1.25



func _on_stun_timer_timeout() -> void:
	print("pos after: "+str(global_position))
	speed_mult = 1
	rotation_speed = 2.25
	in_knockback = false

func _on_nav_timer_timeout() -> void:
	if player != null:
		navAgent.target_position = player.global_position
