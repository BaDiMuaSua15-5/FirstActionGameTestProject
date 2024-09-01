extends State

var player_near: bool
var in_attack: bool = false
@onready var locked_on: bool = false

@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

#var WallDetectRay: RayCast2D = Entity.wallRay
@onready var CancelTimer: Timer = $CancelPursuitTimer

@onready var VisionRay: RayCast2D = $VisionRay
@export var vision_count: int = 9
var view_distance: int = 1200

func enter() -> void:
	super.enter()
	player_near = true
	if !locked_on:
		WeaponComponent.weapon_ready()
		locked_on = true

func exit() -> void:
	super.exit()
	#owner.set_physics_process(false)

func transition(delta: float) -> void:
	check_vision()
	
	if !player_near:
		Entity.player = null
		locked_on = false
		StateMachine.change_state("Ide")
	if in_attack && Entity.player:
		StateMachine.change_state("Combat")
		
	return

var test_hit_vectors: Array[Vector2]
var hit_positions: Array[Vector2]
var direct_to_plyr: Vector2
var last_seen: Vector2
func check_vision() -> void:
	if Entity.player == null || !player_near:
		player_near = false
		return
	
	last_seen = Vector2()
	for index: int in vision_count:
		var direction_to_player := (Entity.player.global_position - Entity.global_position).normalized()
		direct_to_plyr = direction_to_player.rotated(-global_rotation)
		var angle := (index - vision_count / 2) * (PI * 0.15 /(vision_count - 1))
		var cast_vector: Vector2 = view_distance * direction_to_player.rotated(angle)
		
		VisionRay.target_position = cast_vector.rotated(-global_rotation)
		VisionRay.force_raycast_update()
		
		test_hit_vectors.append(cast_vector) 
		
		#await VisionRay.draw
		if VisionRay.is_colliding():
			hit_positions.append(VisionRay.get_collision_point())
			#test_hit_vectors.append(VisionRay.get_collision_point() - global_position)
			var collider := VisionRay.get_collider()
			if collider is PlayerObj:
				if !CancelTimer.is_stopped():
					CancelTimer.stop()
				Entity.target_pos = collider.global_position
				queue_redraw()
				return
	# If player is not in vision, set last seen position and start cancel pursuit Timer
	CancelTimer.wait_time = 5.0
	CancelTimer.start()
	# Saves player's last location
	if Entity.player:
		last_seen = Entity.player.global_position
		Entity.target_pos = last_seen
	player_near = false
	queue_redraw()
	return

func _draw() -> void:
	return
	for i in test_hit_vectors.size():
		
		draw_line(Vector2(), test_hit_vectors[i].rotated(-global_rotation), Color.CRIMSON, 4)
	
	for i in hit_positions.size():
		draw_circle((hit_positions[i] - global_position).rotated(-global_rotation), 10, Color.CHARTREUSE)
	
	#draw_line(Vector2(), direct_to_plyr * 400, Color.BLUE_VIOLET, 7)
	draw_circle((last_seen - global_position).rotated(-global_rotation), 10, Color.CHARTREUSE)
	
	hit_positions.clear()
	test_hit_vectors.clear()

func _on_notice_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerObj:
		player_near = true

func _on_notice_area_2d_body_wexited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		player_near = false
		Entity.player = null

func _on_attack_area_body_entered(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		in_attack = true

func _on_attack_area_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		in_attack = false

func _on_cancel_pursuit_timer_timeout() -> void:
	print("Cancel timeout")
	Entity.target_pos = Entity.origin_pos
