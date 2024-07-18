extends CharacterBody2D
class_name EnemyObj

@export var player: PlayerObj
@onready var HitBox = %HitBoxComponent
var player_near: bool
var active: bool

@export var max_speed = 450
@export var speed: float
var accel = 8
var speed_mult: float = 1
var rotation_speed = 2.25
var knockback = Vector2.ZERO
var is_dead: bool = false
@onready var FSM = %FiniteStateMachine
@onready var wallRay: RayCast2D = $WallDetectRay
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D


func damage(attack: AttackObj):
	if !is_dead:
		knockback = attack.direction * attack.knockback
		speed_mult = 0
		print("pos before: "+str(global_position))
		
		var tween = create_tween()
		tween.tween_property(self, "position", position + knockback, 0.05)
		await tween.finished
		
		speed_mult = 0
		%StunTimer.wait_time = attack.stun_time
		FSM.change_state("Stun")
		knockback = Vector2.ZERO#lerp(knockback, Vector2.ZERO, 0.2)

func _ready():
	HitBox.connect("hitted", damage)
	speed = max_speed
	
	#set_physics_process(false)
	%WeaponComponent.connect("attack_finished", _on_weapons_component_attack_finished)
	%WeaponComponent.connect("attack_started", _on_weapons_component_attack_signal)
	

func _process(delta):
	if player != null:
		rotate_to(player, delta)
	wallRay.global_rotation = 0

func _physics_process(delta):
	if player != null:
		wallRay.target_position = (player.global_position - global_position)
		# check if there are any obstructions between enemy
		# and target
		if wallRay.get_collider() == null: # direct tracking
			var direction = (player.global_position - global_position).normalized()
			velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
		else: # navigation based tracking
			var direction = Vector2()
			navAgent.target_position = player.global_position
			direction = (navAgent.get_next_path_position() - global_position).normalized()
			velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
		move_and_slide()

func rotate_to(target, delta):
	var direction = (target.global_position - global_position).normalized()
	var angleTo = -(transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))

func _on_stun_timer_timeout():
	print("pos after: "+str(global_position))
	speed_mult = 1
	rotation_speed = 2.25

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
