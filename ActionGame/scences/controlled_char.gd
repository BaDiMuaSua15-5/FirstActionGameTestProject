extends CharacterBody2D
class_name PlayerObj

@onready var WeaponManager: WeaponsManager = $Weapons_Manager
@onready var HitBoxComp = %HitBoxComponent
@onready var StaminaComp:StaminaComponent = %StaminaComponent
@onready var Camera: Camera2D = $Camera2D
@export var HealthComponent: PlayerHealthComponent

const DEFAULT_RTA_SPD = 7
var rotationSpeed = DEFAULT_RTA_SPD

@export var MAX_SPEED = 700
@export var speed = MAX_SPEED
var accel = 10
@export var speed_mult: float = 1

@export var DEFAULT_STM_GEN = 200
@export var stamnia_regen: float = DEFAULT_STM_GEN
@export var MAX_STAMINA: float = 200

var can_attack: bool = true
var is_dead: bool
var is_rolling: bool = false
var in_knockback: bool = false

@export var max_health: int = 200
@export var health: int = 200

signal pressed_attack

func _ready():
	StaminaComp.max_stamina = MAX_STAMINA
	print(StaminaComp.max_stamina)
	
	HealthComponent.max_health = max_health
	HealthComponent.health = health
	
	speed = MAX_SPEED
	
	is_dead = false
	HitBoxComp.connect("hitted", damage)
	WeaponManager.connect("attack_finished", _on_weapons_manager_attack_finished)
	WeaponManager.connect("attack_signal", _on_weapons_manager_attack_signal)
	WeaponManager.connect("attack_push", _on_weapons_manager_push_signal)


const MAX_ROLL_TIME: float = 0.37
var roll_time: float = MAX_ROLL_TIME
func _process(delta):
	if is_dead:
		return
	
	#print('Stamina regen: ', stamnia_regen)
	StaminaComp.stamina += stamnia_regen * delta
	
	if is_rolling: #Check rolling status
		if (roll_time <= 0.0): # When end of the roll
			if !in_push: #Check if the roll force is an atk_push
				#If not then start the stamnia_regen Timer
				print("Rolled")
				%StaminaGenTimer.wait_time = 0.5
				%StaminaGenTimer.start()
			else:
				print("Pushed")
				pass #If is atk_push then let the atk_finish Signal start the Timer
				
			roll_time = MAX_ROLL_TIME
			is_rolling = false
			in_push = false
			HitBoxComp.get_child(0).disabled = false
			modulate = Color(1, 1, 1)
			return
		roll_time -= delta


var roll_dir: Vector2
var knockback_dir: Vector2
var knockback_mult: float = 1
func _physics_process(delta):
	if is_dead:
		return
	
	var target = get_global_mouse_position()
	if target != null:
		rotate_to(target, delta)
	
	
	if in_knockback: # Knockback movement
		velocity = knockback_dir * 7
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
		
	if is_rolling: # Rolling(dodge, atk_push) movement
		velocity = roll_dir * 1150
		move_and_slide()
		Camera.position = Camera.position.lerp(position, 1 * delta)
		return
		
	
	Camera.position = Camera.position.lerp(position, 3 * delta)
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
	
	roll_input(direction)
	move_and_slide()



func _input(event):
	if !is_dead and StaminaComp.stamina > 0:
		if event.is_action_pressed("attack") && !is_rolling:
			pressed_attack.emit()

func damage(attack: AttackObj):
	if !is_dead:
		speed_mult = 0
		%StunTimer.wait_time = attack.stun_time
		%StunTimer.start()
		can_attack = false
		in_knockback = true
		modulate = "ff0000"
		knockback_dir = attack.direction * attack.knockback

func rotate_to(target, delta):
	var direction = (target - global_position).normalized()
	var angleTo = (-transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

# Process the roll input
func roll_input(direction: Vector2):
	if Input.is_action_just_pressed("dodge") and StaminaComp.stamina > 0 and !is_rolling and !WeaponManager.isAttacking:
		%StaminaGenTimer.stop()
		is_rolling = true
		roll_time = MAX_ROLL_TIME
		#speed_mult = 0
		stamnia_regen = 0
		StaminaComp.stamina -= 4
		HitBoxComp.get_child(0).disabled = true
		modulate = Color(0, 0.81176471710205, 0)
		
		if direction == Vector2.ZERO:
			roll_dir = global_transform.y.normalized()
		else:
			roll_dir = direction.normalized()

func _on_weapons_manager_attack_signal():
	%StaminaGenTimer.stop()
	print("Attack intercept")
	is_rolling = false
	speed_mult = 0
	stamnia_regen = 0
	rotationSpeed = 1.5
	StaminaComp.stamina -= WeaponManager.Current_Weapon.Stamina_Cost

var in_push:bool = false
func _on_weapons_manager_push_signal():
	if is_dead:
		return
	
	var attack_push= (-global_transform.y).normalized()
	
	roll_dir = attack_push
	roll_time = 0.05
	is_rolling = true
	in_push = true

func _on_weapons_manager_attack_finished():
	speed_mult = 1
	rotationSpeed = DEFAULT_RTA_SPD
	%StaminaGenTimer.stop()
	
	print("Stamina: ", StaminaComp.stamina)
	if (StaminaComp.stamina <= 0.0):
		%StaminaGenTimer.wait_time = 0.9
	else:
		%StaminaGenTimer.wait_time = 0.4
	%StaminaGenTimer.start()

func _on_stun_timer_timeout():
	speed_mult = 1
	can_attack = true
	in_knockback = false
	modulate = Color(1, 1, 1)

func _on_stamina_gen_timer_timeout():
	print("Stamina gen timer out")
	stamnia_regen = DEFAULT_STM_GEN
