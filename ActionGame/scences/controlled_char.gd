extends CharacterBody2D
class_name PlayerObj

@export var ghost_node: PackedScene

@onready var APComp: APComponent = %APComponent
@onready var WeaponManager: WeaponsManager = $Weapons_Manager
@onready var HitBoxComp: HitBoxComponent = %HitBoxComponent
@onready var StaminaComp:StaminaComponent = %StaminaComponent
@onready var Camera: Camera2D = ($Shakeable_Camera as ShakeableCamera).Camera
@export var HealthComponent: PlayerHealthComponent

const DEFAULT_RTA_SPD = 7
var rotationSpeed: int = DEFAULT_RTA_SPD

@export var MAX_SPEED: int = 700
@export var speed: int = MAX_SPEED
@export var speed_mult: float = 1
var accel: int = 10

@export var DEFAULT_STM_GEN: float = 200
@export var stamnia_regen: float = DEFAULT_STM_GEN
@export var MAX_STAMINA: float = 200

var can_attack: bool = true
var is_dead: bool
var is_rolling: bool = false
var in_knockback: bool = false

var attacker_queue: Array[int] # Array for enemies to queue for attacks
var atk_queue_max: int = 2

@export var max_health: int = 200
@export var health: int = 200

signal pressed_attack

func _ready() -> void:
	StaminaComp.max_stamina = MAX_STAMINA
	print(StaminaComp.max_stamina)
	
	HealthComponent.max_health = max_health
	HealthComponent.health = health
	
	speed = MAX_SPEED
	
	is_dead = false
	#$AnimatedSprite2D.top_level = true
	#$AnimatedSprite2D.scale = scale
	origin_pos = global_position

const MAX_ROLL_TIME: float = 0.37
var roll_time: float = MAX_ROLL_TIME
func _process(delta: float) -> void:
	if is_dead:
		return
	
	var target: Vector2 = get_global_mouse_position()
	if target == null:
		return
		
	rotate_to(target, delta)
	StaminaComp.add(DEFAULT_STM_GEN * delta)
	
	#StaminaComp.stamina += stamnia_regen * delta
	
	#Check rolling status
	if is_rolling: 
		# When end of the roll
		if (roll_time <= 0.0):
			# If the roll force is an atk_push
			if !in_push: 
				#If is rolling then start the stamnia_regen_delay Timer
				StaminaComp.delay_regen_timer(0.5)
				modulate = Color(1, 1, 1)
				$AnimatedSprite2D.modulate = Color(1, 1, 1)
			# If is atk_push then let the atk_finish Signal start the Timer
			else: 
				in_push = false
			$DashEffectTimer.stop()
			roll_time = MAX_ROLL_TIME
			is_rolling = false
			roll_dir = Vector2.ZERO
			HitBoxComp.get_child(0).disabled = false
			return
		roll_time -= delta
		
	animate_sprite(target - global_position)
	return

var roll_dir: Vector2
var knockback_dir: Vector2
var knockback_mult: float = 1
var count_test: float = 1.0
var origin_pos: Vector2
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if in_knockback: # Knockback movement
		velocity = knockback_dir * 10
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		
		var camera_curve := delta * delta * (3.0 - 2.0 * delta)
		Camera.global_position = Camera.global_position.lerp(global_position, 75 * camera_curve)
		return
		
	if is_rolling: # Rolling(dodge, atk_push) movement
		if in_push:
			velocity = roll_dir * 750.0
		else:
			velocity = roll_dir * 1150.0
		move_and_slide()
		roll_dir = roll_dir.lerp(Vector2.ZERO, delta * 0.5)
		
		var direction_to_mouse := get_global_mouse_position() - global_position
		direction_to_mouse = direction_to_mouse / 2
		direction_to_mouse.x = clamp(direction_to_mouse.x, -50, 50)
		direction_to_mouse.y = clamp(direction_to_mouse.y, -50, 50)
	
		var mid_point_to_mouse :Vector2 = global_position
		var camera_curve := delta * delta * (3.0 - 2.0 * delta)
		Camera.global_position = Camera.global_position.lerp(mid_point_to_mouse, 20 * camera_curve)
		return
	
	# Normal movement & Camera
	var direction_to_mouse := get_global_mouse_position() - global_position
	direction_to_mouse = direction_to_mouse / 2
	direction_to_mouse.x = clamp(direction_to_mouse.x, -200, 200)
	direction_to_mouse.y = clamp(direction_to_mouse.y, -200, 200)
	var mid_point_to_mouse :Vector2 = global_position + direction_to_mouse
	var camera_curve := delta * delta * (3.0 - 2.0 * delta)
	Camera.global_position = Camera.global_position.lerp(mid_point_to_mouse, 75 * camera_curve)
	
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		direction = direction * speed_mult
		accelerate(speed * 5 * delta, direction * speed)
	else:
		apply_friction(speed * 5 * delta)
	roll_input(direction)
	move_and_slide()

func accelerate(acceleration: float, target_velocity: Vector2) -> void:
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration)
	velocity.y = move_toward(velocity.y, target_velocity.y, acceleration)

func apply_friction(amount: float) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if is_dead || is_rolling || in_knockback:
		return
	
	#if event.is_action_pressed("attack"):
		#APComp.accumulate(30)

func hitted(attack: AttackObj) -> void:
	if !is_dead:
		speed_mult = 0
		%StunTimer.wait_time = attack.stun_time
		%StunTimer.start()
		can_attack = false
		in_knockback = true
		damage_flash()
		knockback_dir = attack.direction * attack.knockback
		Global.shake_camera(0.75)
		Global.play_hit_sound()

func damage_flash() -> void:
	modulate = "ff0000"
	$AnimatedSprite2D.modulate = "ff0000"
	await get_tree().create_timer(0.05)
	modulate = Color(1, 1, 1)
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.05)
	modulate = "ff0000"
	$AnimatedSprite2D.modulate = "ff0000"

func _on_death() -> void:
	self.modulate = "ff0000"
	Global.play_kill_sound()
	Global.shake_camera(1)
	
	is_dead = true
	set_physics_process(false)
	await get_tree().create_timer(1.7).timeout

func rotate_to(target: Vector2, delta: float) -> void:
	var direction := (target - global_position).normalized()
	var angleTo: float = (-transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func animate_sprite(direction: Vector2) -> void:
	$AnimatedSprite2D.global_position = position
	$AnimatedSprite2D.rotation = -rotation
	var h_length: float = abs(direction.x)
	var v_length: float = abs(direction.y)
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	if velocity == Vector2.ZERO:
		if h_length >= v_length:
			$AnimatedSprite2D.play("idle_right")
		else:
			if direction.y < 0:
				$AnimatedSprite2D.play("idle_up")
			else:
				$AnimatedSprite2D.play("idle_down")
	else:
		if h_length >= v_length:
			$AnimatedSprite2D.play("move_right")
		else:
			if direction.y < 0:
				$AnimatedSprite2D.play("move_up")
			else:
				$AnimatedSprite2D.play("move_down")

# Process the roll input
func roll_input(direction: Vector2) -> void:
	if Input.is_action_just_pressed("dodge") and StaminaComp.stamina > 0 and !is_rolling and !WeaponManager.isAttacking:
		%StaminaGenTimer.stop()
		is_rolling = true
		roll_time = MAX_ROLL_TIME
		stamnia_regen = 0
		StaminaComp.deplete_stamina(20)
		HitBoxComp.get_child(0).disabled = true
		modulate = Color(0, 0.81176471710205, 0)
		$AnimatedSprite2D.modulate = Color(0, 0.81176471710205, 0)
		$DashEffectTimer.start()
		
		if direction == Vector2.ZERO:
			roll_dir = global_transform.y.normalized()
		else:
			roll_dir = direction.normalized()

func _on_weapons_manager_attack_signal() -> void:
	%StaminaGenTimer.stop()
	#print("Attack intercept")
	speed_mult = 0
	stamnia_regen = 0
	rotationSpeed = 1.5
	StaminaComp.deplete_stamina(WeaponManager.Current_Weapon.Stamina_Cost)

var in_push:bool = false
func _on_weapons_manager_push_signal() -> void:
	if is_dead:
		return
	
	var attack_push := (-global_transform.y).normalized()
	roll_dir = attack_push
	roll_time = 0.05
	rotationSpeed = DEFAULT_RTA_SPD
	is_rolling = true
	in_push = true

func _on_weapons_manager_attack_finished() -> void:
	speed_mult = 1
	rotationSpeed = DEFAULT_RTA_SPD
	
	#print("Stamina: ", StaminaComp.stamina)
	# Delay stamina regen
	if (StaminaComp.get_stamina() <= 0.0):
		StaminaComp.delay_regen_timer(2)
	else:
		StaminaComp.delay_regen_timer(0.4)

func _on_stun_timer_timeout() -> void:
	speed_mult = 1
	can_attack = true
	in_knockback = false
	knockback_dir = Vector2.ZERO
	modulate = Color(1, 1, 1)
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

func _on_stamina_gen_timer_timeout() -> void:
	#print("Stamina gen timer out")
	#stamnia_regen = DEFAULT_STM_GEN
	pass

func add_dash_effect() -> void:
	var effect := ghost_node.instantiate() as DashEffect
	effect.set_property(position, $MeshInstance2D.scale, -roll_dir)
	#get_tree().current_scene.get_node("Effect").add_child(effect)
	if get_parent().get_node("Effect"):
		get_parent().get_node("Effect").add_child(effect)

func _on_dash_effect_timer_timeout() -> void:
	add_dash_effect()

# Attacker queue for attack
func _on_attacker_queue(attacker_id: int) -> void:
	var result_index := attacker_queue.find(attacker_id)
	if attacker_queue.size() < 3 && result_index < 0:
		attacker_queue.append(attacker_id)

# Attacker check if in queue to attack
func _on_attacker_dequeue(attacker_id: int) -> bool:
	var result_index := attacker_queue.find(attacker_id)
	print(result_index)
	if result_index >= 0:
		attacker_queue.remove_at(result_index)
		return true
	return false
	
func attacker_in_queue(attacker_id: int) -> bool:
	var result_index := attacker_queue.find(attacker_id)
	if result_index >= 0:
		return true
	return false
