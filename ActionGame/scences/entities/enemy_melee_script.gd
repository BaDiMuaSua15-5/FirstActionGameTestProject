extends CharacterBody2D
class_name EnemyMelee

const SPEED = 450.0
var speed_mult: float = 1
var rotation_speed: float = 2.25
var rotation_mult: float = 1
var origin_rotation_vector: Vector2 = Vector2.UP
var origin_pos: Vector2
@export var MAX_HEALTH: int

@export var StateMachine: FiniteStateMachine
@export var Health: PlayerHealthComponent
@onready var HealthBar: ProgressBar = $Debug/HealthBar
@export var HitBox: HitBoxComponent
@export var WeaponComp: WeaponComponent
@export var Upgrades: UpgradesComponent

# Context Behaviors
@export var look_ahead: float = 300.0 + 130.0
@export var num_rays: int = 32
var ray_directions: Array[Vector2] = []
var interest: Array[float] = []
var danger: Array[float] = []
var chosen_dir: Vector2 = Vector2.ZERO
const CONTEXT_RAY_DETECT_MASK := 0b1111
var target_position: Vector2
var player: PlayerObj
var strafe_distance: float

var is_dead: bool
signal died
var in_combat: bool
var in_knockback: bool
var knockback_time: float
var knockback_dir: Vector2
var in_atk_push: bool
var atk_push_dir: Vector2
var atk_push_dur: float
var PUSH_DURATION_DEF: float = 0.36

func _ready() -> void:
	Health.max_health = MAX_HEALTH
	Health.health = MAX_HEALTH
	Health.health_depleted.connect(_on_death)
	Health.connect("health_change", _on_health_change)
	call_deferred("_on_health_change", Health.health, Health.max_health)
	
	WeaponComp.attack_finished.connect(_on_weapon_attack_finished)
	WeaponComp.attack_started.connect(_on_weapon_attack_start)
	
	strafe_distance = randi_range(500, 600)
	origin_pos = global_position
	origin_rotation_vector = Vector2.UP.rotated(global_rotation)
	target_position = origin_pos
	set_context_rays()
	$Exclaimation.visible = false

func _process(delta: float) -> void:
	if in_atk_push:
		if atk_push_dur > 0:
			atk_push_dur -= delta
		else:
			in_atk_push = false

	%debug.rotation = -global_rotation
	$Debug.global_rotation = 0

func _physics_process(delta: float) -> void:
	if (in_knockback):
		velocity = knockback_dir * 7.0
		knockback_dir = knockback_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if (in_atk_push):
		velocity = atk_push_dir * 750.0
		atk_push_dir = atk_push_dir.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		return
	
	if is_dead:
		apply_friction(SPEED * delta * 5)
		move_and_slide()
		return
		
	set_interests()
	set_danger()
	choose_direction()
	var desired_velocity: Vector2
	desired_velocity = chosen_dir.rotated(rotation) * SPEED
	if int(desired_velocity.length()) == 0:
		rotate_to(global_position + origin_rotation_vector * 100, delta)
		velocity = Vector2.ZERO
	else:
		var distance_to_target := (target_position - global_position).length()
		desired_velocity = desired_velocity * speed_mult
		if distance_to_target > SPEED * delta:
			accelerate(SPEED * delta * 5, desired_velocity)
		else:
			var max := distance_to_target / delta
			var dir :Vector2= desired_velocity.normalized() * max * speed_mult
			velocity = dir
		rotate_to(target_position, delta)
	move_and_slide()
	pass


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


## Context Functions
func _draw() -> void:
	if ray_directions.is_empty() || interest.is_empty():
		return
	for i in num_rays:
		draw_line(Vector2(), (ray_directions[i] * look_ahead * interest[i]), Color.CHARTREUSE, 3.0)
	
	draw_line(Vector2(), chosen_dir * SPEED, Color.DEEP_PINK, 3.0)


func set_context_rays() -> void:
	var ContextRays := $ContextRays as Node2D
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


func set_interests() -> void: 
	var next_position := target_position - global_position
	var path_direction: Vector2 = next_position
	# Movement in Combat
	if in_combat:
		var distance_to_player := (player.global_position - global_position).length()
		# Strafe arounf player
		var stafe_direction := Vector2(path_direction.y, -path_direction.x)
		stafe_direction = stafe_direction if randi_range(0, 1) == 1 else -stafe_direction
		path_direction = stafe_direction
		# If player is too close move away
		if distance_to_player < 500:
			path_direction = transform.y
	for i in num_rays:
		var d := ray_directions[i].rotated(rotation).dot(path_direction.normalized())
		interest[i] = max(0, d)


func set_danger() -> void:
	var ContextRays := $ContextRays as Node2D
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


func hitted(attack: AttackObj) -> void:
	if is_dead:
		print(self, ", Is dead")
		return
	# Player accumulate AP when hit enemy
	if attack.Attacker is PlayerObj:
		var player := attack.Attacker as PlayerObj
		player.APComp.accumulate(attack.ap_accumulation)
		Global.hitstop_effect(0.25, 0.14)
	
	if Global.camera:
		# Shake camera based on attack object
		if attack.Attacker is Throwable:
			Global.shake_camera(0.65)
		else:
			Global.shake_camera(0.35)
	Global.play_hit_sound()
	
	if Health.health == 0:
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
	knockback_time = attack.stun_time
	StateMachine.change_state("Stunned")
	damage_flash()
	
func damage_flash() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hitted")
	modulate = "00d6be"
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)

func _on_death() -> void:
	self.modulate = "ff0000"
	Global.play_kill_sound()
	Global.shake_camera(0.65)
	
	var collision := HitBox.get_child(0)
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.6)
	await tween.finished
	died.emit()
	queue_free()


func _on_weapon_attack_start() -> void:
	speed_mult = 0
	rotation_mult = 0.5
	atk_push_dir = -transform.y
	in_atk_push = true
	atk_push_dur = PUSH_DURATION_DEF
	
func _on_weapon_attack_finished() -> void:
	speed_mult = 1
	rotation_mult = 1

func _on_health_change(health: int, max_health: int) -> void:
	HealthBar.max_value = max_health
	HealthBar.value = health
