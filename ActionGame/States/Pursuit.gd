extends State

var player_near: bool
var in_attack: bool = false
@onready var locked_on: bool = false

@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

@onready var WallDetectRay: RayCast2D = $WallDetectRay
@onready var CancelTimer: Timer = $CancelPursuitTimer

func enter() -> void:
	super.enter()
	if !locked_on:
		WeaponComponent.weapon_ready()
		locked_on = true

func exit() -> void:
	super.exit()
	#owner.set_physics_process(false)

func transition(delta: float) -> void:
	if player_near == false || Entity.player == null:
		locked_on = false
		if Entity.player:
			Entity.target_pos = Entity.player.position
			Entity.player = null
		CancelTimer.start()
		StateMachine.change_state("Ide")
		
	if in_attack:
		StateMachine.change_state("Combat")
	
	## Temporally discard movement controlled by state
	#if Entity.player != null:
		#WallDetectRay.target_position = (Entity.player.position - Entity.position)
		## check if there are any obstructions between enemy
		## and target
		#var direction: Vector2
		##direction = (player.global_position - global_position).normalized()
		#if WallDetectRay.get_collider() == null: # direct tracking
			#direction = (Entity.player.position - Entity.position).normalized()
		#elif Entity.navAgent.get_next_path_position() != Vector2.ZERO: # navigation based tracking
			#var next_position := Entity.navAgent.get_next_path_position()
			#direction = (next_position - Entity.position).normalized()
		#Entity.velocity = Entity.velocity.lerp(direction * Entity.speed, Entity.accel * delta)
		#Entity.move_and_slide()
		#Entity.rotate_to(Entity.player.position, delta)
		

func _on_notice_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerObj:
		player_near = true

func _on_notice_area_2d_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		player_near = false

func _on_attack_area_body_entered(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		in_attack = true

func _on_attack_area_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		in_attack = false

func _on_cancel_pursuit_timer_timeout() -> void:
	Entity.target_pos = Entity.origin_pos
