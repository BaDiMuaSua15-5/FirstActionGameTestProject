extends State

@export var Entity: EnemyMelee
var cast_count: int = 32 * 5
var view_dist: float = 800
@export var ObstructionRay: RayCast2D
var test_hit_positions: Array[Vector2]


func enter() -> void:
	super.enter()


func exit() -> void:
	super.exit()
	return


func transition_process(delta: float) -> void:
	if Entity.is_dead:
		return
	return


func transition_physics_process(delta: float) -> void:
	if Entity.is_dead:
		return
	if Entity.player:
		StateMachine.change_state("Pursuit")
		return
	if (Global.player.global_position - global_position).length() > 1000:
		return
	for index in cast_count:
		var angle := index * PI * 2.0 / cast_count
		var cast_vector: Vector2 = Vector2.UP.rotated(angle) * view_dist
		
		ObstructionRay.target_position = cast_vector
		ObstructionRay.force_raycast_update()
		
		
	
		if ObstructionRay.is_colliding():
			var collider := ObstructionRay.get_collider()
			cast_vector = ObstructionRay.get_collision_point() - global_position
			if collider is PlayerObj:
				Entity.player = collider
				ObstructionRay.enabled = false
				break
		test_hit_positions.append(cast_vector) 
	#queue_redraw()
	#Entity.player = null
	return
	

func _draw() -> void:
	return
	
	for hit:Vector2 in test_hit_positions:
		draw_circle((hit), 10, Color.CHARTREUSE)
		draw_line(Vector2(0, 0), (hit), Color.CRIMSON, 2)
	test_hit_positions.clear()
	return
