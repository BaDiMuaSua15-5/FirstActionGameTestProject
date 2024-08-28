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
	var cast_count: int = int(angle_cone_of_vision / angle_between_rays) + 1
	
	for index: int in cast_count:
		var angle := angle_between_rays * (index - int(cast_count / 2.0))
		var cast_vector: Vector2 = view_distance * Vector2.UP.rotated(angle)
		
		test_hit_positions.append(cast_vector)
	queue_redraw()
	
	Entity.player= null

func transition(delta: float) -> void:
	if Entity.is_dead:
		return
	
	if (player_near):
		StateMachine.change_state("Pursuit")
		return
		
	var cast_count: int = int(angle_cone_of_vision / angle_between_rays) + 1
	
	for index: int in cast_count:
		var angle := angle_between_rays * (index - int(cast_count / 2.0))
		var cast_vector: Vector2 = view_distance * Vector2.UP.rotated(angle)
		
		ObstructionRay.target_position = cast_vector
		ObstructionRay.force_raycast_update()
		
		test_hit_positions.append(cast_vector) 
	
		
		#await ObstructionRay.draw
		if ObstructionRay.is_colliding():
			hit_pos = ObstructionRay.get_collision_point()
			var collider := ObstructionRay.get_collider()
			if collider is PlayerObj:
				player_near = true
				Entity.player = collider
				ObstructionRay.enabled = false
				#break
			
	queue_redraw()
	
		
func _draw() -> void:
	return
	#draw_circle((hit_pos - global_position).rotated(global_rotation), 10, Color.CRIMSON)
	#draw_line(Vector2(0, 0), (hit_pos - global_position).rotated(global_rotation), Color.CRIMSON, 1)
	
	for hit:Vector2 in test_hit_positions:
		draw_circle((hit - global_position).rotated(global_rotation), 5, Color.CRIMSON)
		draw_line(Vector2(0, 0), (hit), Color.CRIMSON, 2)
	test_hit_positions.clear()
