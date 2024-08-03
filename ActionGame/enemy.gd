extends CharacterBody2D
class_name EnemyObj

@export var player: PlayerObj

@export var max_speed = 450
@export var speed: float
@export var speed_mult: float = 1
var accel = 8

var rotation_speed = 2.25
var is_dead: bool = false
var in_knockback: bool = false

@onready var HitBox = %HitBoxComponent
@onready var FSM = %FiniteStateMachine
@onready var wallRay: RayCast2D = $WallDetectRay
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D
@onready var NavTimer: Timer = $NavTimer
@onready var StunTimer: Timer = %StunTimer




func _ready():
	HitBox.connect("hitted", damage)
	speed = max_speed
	%WeaponComponent.connect("attack_finished", _on_weapons_component_attack_finished)
	%WeaponComponent.connect("attack_started", _on_weapons_component_attack_signal)
	

func _process(delta):
	if player != null:
		rotate_to(player, delta)
	wallRay.global_rotation = 0

var knockback_dir: Vector2
func _physics_process(delta):
	if (in_knockback):
		velocity = knockback_dir * 7
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if player != null:
		wallRay.target_position = (player.global_position - global_position)
		# check if there are any obstructions between enemy
		# and target
		if wallRay.get_collider() == null: # direct tracking
			var direction = (player.global_position - global_position).normalized()
			velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
		elif navAgent.get_next_path_position() != Vector2.ZERO: # navigation based tracking
			var direction: Vector2
			direction = (navAgent.get_next_path_position() - global_position).normalized()
			velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
		move_and_slide()
#END _physics_process

func rotate_to(target, delta):
	var direction = (target.global_position - global_position).normalized()
	var angleTo = -(transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))

func damage(attack: AttackObj):
	if !is_dead:
		#====Knockback fix======
		knockback_dir = attack.direction * attack.knockback
		in_knockback = true
		#=======================
		speed_mult = 0
		print("pos before: "+str(global_position))
		
		
		StunTimer.wait_time = attack.stun_time
		FSM.change_state("Stun")
		#knockback_dir = lerp(knockback_dir, Vector2.ZERO, 0.2)

func _on_weapons_component_attack_signal():
	print('start')
	speed_mult = 0
	rotation_speed = 1
	var attack_push = (%FacingNode.global_position - global_position).normalized()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + attack_push * 100, 0.10)
	
func _on_weapons_component_attack_finished():
	speed_mult = 1
	rotation_speed = 1.25

func _on_close_area_body_entered(body):
	if body is PlayerObj:
		speed_mult = 0

func _on_close_area_body_exited(body):
	if body is PlayerObj:
		speed_mult = 1

func _on_stun_timer_timeout():
	print("pos after: "+str(global_position))
	speed_mult = 1
	rotation_speed = 2.25
	in_knockback = false

func _on_nav_timer_timeout():
	if player != null:
		navAgent.target_position = player.global_position
