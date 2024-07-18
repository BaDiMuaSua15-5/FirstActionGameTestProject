extends CharacterBody2D
class_name PlayerObj

@onready var WeaponManager = $Weapons_Manager
@onready var HitBoxComp = %HitBoxComponent
@onready var StaminaComp:StaminaComponent = %StaminaComponent
@onready var Camera: Camera2D = $Camera2D

var rotationSpeed = 7
var speed
var accel = 10
const MAX_SPEED = 700
@export var speed_mult: float = 1
@export var stamnia_regen: float = 7
const DEFAULT_STM_GEN = 50
var can_attack = true
var is_dead: bool
var is_rolling: bool = false
signal pressed_attack


func damage(attack: AttackObj):
	if !is_dead:
		var knockback = attack.direction * attack.knockback
		speed_mult = 0
		%StunTimer.wait_time = attack.stun_time
		%StunTimer.start()
		can_attack = false
		var tween = create_tween()
		tween.tween_property(self, "position", position+knockback, 0.05)
		

func _on_stun_timer_timeout():
	speed_mult = 1
	can_attack = true

func _ready():
	is_dead = false
	speed = MAX_SPEED
	HitBoxComp.connect("hitted", damage)
	WeaponManager.connect("attack_finished", _on_weapons_manager_attack_finished)
	WeaponManager.connect("attack_signal", _on_weapons_manager_attack_signal)
	
	WeaponManager.connect("attack_push", _on_weapons_manager_push_signal)

func _process(delta):
	if StaminaComp.stamina < StaminaComp.max_stamina:
		StaminaComp.stamina += stamnia_regen * delta

var roll_dir: Vector2
func _physics_process(delta):
	
	var target = get_global_mouse_position()
	if target != null:
		rotate_to(target, delta)
	if is_rolling:
		velocity = roll_dir * 900
		move_and_slide()
		Camera.position = Camera.position.lerp(position, 1 * delta)
		return
	Camera.position = Camera.position.lerp(position, 3 * delta)
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(direction * speed * speed_mult, accel * delta)
	
	if Input.is_action_just_pressed("dodge") and StaminaComp.stamina > 0 and !is_rolling:
		roll_input()
		if direction == Vector2.ZERO:
			roll_dir = -(target - global_position).normalized()
		else:
			roll_dir = direction
	move_and_slide()



func _input(event):
	if !is_dead and StaminaComp.stamina > 0:
		if event.is_action_pressed("attack"):
			pressed_attack.emit()

func rotate_to(target, delta):
	var direction = (target - global_position).normalized()
	var angleTo = (-transform.y).angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))


func roll_input():
	%StaminaGenTimer.stop()
	is_rolling = true
	speed_mult = 0
	stamnia_regen = 0
	StaminaComp.stamina -= 4
	HitBoxComp.get_child(0).disabled = true
	modulate = Color(0, 0.81176471710205, 0)
	await get_tree().create_timer(0.45).timeout
	
	is_rolling = false
	speed_mult = 1
	HitBoxComp.get_child(0).disabled = false
	modulate = Color(1, 1, 1)
	%StaminaGenTimer.wait_time = 0.5
	%StaminaGenTimer.start()

func _on_weapons_manager_attack_signal():
	is_rolling = false
	%StaminaGenTimer.stop()
	speed_mult = 0
	rotationSpeed = 0
	StaminaComp.stamina -= 4
	stamnia_regen = 0
	if (StaminaComp.stamina == 0):
		%StaminaGenTimer.wait_time = 0.9
	else:
		%StaminaGenTimer.wait_time = 0.4
	return

func _on_weapons_manager_push_signal():
	
	#var attack_push= (get_global_mouse_position() - global_position).normalized() # Attack direction on mouse
	var attack_push= (-transform.y).normalized()
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "global_position", global_position + attack_push * 150, 0.10).finished
	return


func _on_weapons_manager_attack_finished():
	speed_mult = 1
	rotationSpeed = 100
	%StaminaGenTimer.start()

func _on_stamina_gen_timer_timeout():
	stamnia_regen = DEFAULT_STM_GEN
