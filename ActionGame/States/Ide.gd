extends State

var player_near: bool = false
@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

@export var angle_cone_of_vision: float = deg_to_rad(90)
@export var view_distance: float = 800
@export var angle_between_rays: float = deg_to_rad(90/10)
var hit_pos: Vector2

var test_hit_positions: Array[Vector2]

@onready var ObstructionRay: RayCast2D = $RayCastDetection 

func enter() -> void:
	super.enter()
	player_near = false
	WeaponComponent.weapon_unready()
	print("Vector up:",Vector2.UP)
	
	ObstructionRay.enabled = true

func transition(delta: float) -> void:
	if (player_near):
		StateMachine.change_state("Pursuit")
		return
		
	var cast_count: int = int(angle_cone_of_vision / angle_between_rays) + 1
	
	for index: int in cast_count:
		var angle := angle_between_rays * (index - int(cast_count / 2.0))
		var cast_vector: Vector2 = view_distance * Vector2.UP.rotated(angle)
		
		#test_hit_positions.append(cast_vector)
		ObstructionRay.target_position = cast_vector
		ObstructionRay.force_raycast_update()
		
		#await ObstructionRay.draw
		if ObstructionRay.is_colliding():
			#enity_object.player = ObstructionRay.get_collider()
			#enity_object.obtruct_by_wall = true
			hit_pos = ObstructionRay.get_collision_point()
			var collider := ObstructionRay.get_collider()
			queue_redraw()
			if collider is PlayerObj:
				player_near = true
				Entity.player = collider
				ObstructionRay.enabled = false
				ObstructionRay.target_position = Vector2.ZERO
				break
			
	queue_redraw()
	
		
#func _draw() -> void:
	#draw_circle((hit_pos - global_position).rotated(global_rotation), 10, Color.CRIMSON)
	#draw_line(Vector2(0, 0), (hit_pos - global_position).rotated(global_rotation), Color.CRIMSON, 1)
	#
	##for hit:Vector2 in test_hit_positions:
		##draw_circle((hit), 5, Color.CRIMSON)
		##draw_line(Vector2(), (hit), Color.CRIMSON, 1)

func _on_notice_area_2d_body_entered(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		#player_near = true
		#Entity.player = body
		pass
