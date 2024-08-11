extends Node2D

@export var enity_object: EnemyObj
@export var angle_cone_of_vision: float = deg_to_rad(180)
@export var view_distance: float = 800
@export var angle_between_rays: float = deg_to_rad(10)
var hit_pos: Vector2

@onready var ObstructionRay: RayCast2D = $RayCastDetection 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(ObstructionRay)
	generate_raycasts()

func generate_raycasts() -> void:
	# angle_cone_of_vision / angle_between_rays is the number of spaces
	# between the rays, so + 1 to get the number of rays
	#var cast_count: int = int(angle_cone_of_vision / angle_between_rays) + 1
	#
	#for index: int in cast_count:
		#var ray: RayCast2D = RayCast2D.new()
		#var angle := angle_between_rays * (index - int(cast_count / 2.0))
		#ray.target_position = Vector2.UP.rotated(angle) * view_distance
		#add_child(ray)
		#ray.enabled = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#for ray: RayCast2D in get_children():
		#if ray.is_colliding() && ray.get_collider() is PlayerObj:
			#enity_object.player = ray.get_collider()
	
	var cast_count: int = int(angle_cone_of_vision / angle_between_rays) + 1
	
	for index: int in cast_count:
		var angle := angle_between_rays * (index - int(cast_count / 2.0))
		var cast_vector: Vector2 = view_distance * Vector2.UP.rotated(angle)
		
		ObstructionRay.target_position = cast_vector
		ObstructionRay.force_raycast_update()
		
		if ObstructionRay.is_colliding():
			#enity_object.player = ObstructionRay.get_collider()
			#enity_object.obtruct_by_wall = true
			hit_pos = ObstructionRay.get_collision_point()
			print("Hit_pos: ", hit_pos)
			queue_redraw()
			break
			
		hit_pos = cast_vector
		queue_redraw()
			
		enity_object.obtruct_by_wall = false

func _draw() -> void:
	#if enity_object.player:ww
	draw_circle((hit_pos - enity_object.position).rotated(-enity_object.rotation), 5, Color.CRIMSON)
	draw_line(Vector2(), (hit_pos - enity_object.position).rotated(-enity_object.rotation), Color.CRIMSON, 1)
