extends CharacterBody2D


@export var max_speed: int = 700
@export var steer_force: float = 12
@export var look_ahead: float = 100.0
@export var num_rays: int = 16

# context array
var ray_directions: Array[Vector2] = []
var interest: Array[float] = []
var danger: Array[float] = []

var chosen_dir: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO

func _ready() -> void:
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle: float = i * 2.0 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
	queue_redraw()
	
var draw_dangers: Array[Vector2]
func _draw() -> void:
	#draw_circle((hit_pos - global_position).rotated(global_rotation), 10, Color.CRIMSON)
	#draw_line(Vector2(0, 0), (hit_pos - global_position).rotated(global_rotation), Color.CRIMSON, 1)
	print("=== Vectors ===")
	for i in num_rays:
		print(ray_directions[i].rotated(global_rotation))
		draw_line(Vector2(0.0, 0.0), (ray_directions[i] * look_ahead * interest[i]), Color.CRIMSON, 3.0)
	print("=== end ===")	
	print("=== Dangers ===")
	for i in num_rays:
		print(danger[i])
		#draw_line(Vector2.ZERO, ray_directions[i] * 100, Color.CRIMSON, 3.0)
	print("=== end ===")	
	pass

func _physics_process(delta: float) -> void:
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity := chosen_dir.rotated(rotation) * max_speed
	
	_velocity = _velocity.lerp(desired_velocity, delta * 7)
	#_velocity = desired_velocity
	rotation = _velocity.angle()
	move_and_collide(_velocity * delta)
	queue_redraw()
	
func set_interest() -> void:
	# Set interest in each slot based on world direction
	if owner and owner.has_method("get_dpath_direction"):
		print("Has method")
		var path_direction: Vector2= owner.get_path_direction(position)
		for i in num_rays:
			var d := ray_directions[i].rotated(rotation).dot(path_direction.normalized())
			interest[i] = max(0, d) * 5
	# If no world path, use default interest
	else:
		set_default_interest()

func set_default_interest() -> void:
	# Default to moving forward
	print("=== Interest ===")
	for i in num_rays:
		var d := ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d) * 5
		print(interest[i])
	print("=== end ===")	

func set_danger() -> void:
	# Cast rays to find danger directions
	var space_state := get_world_2d().direct_space_state
	
	#print("=== Dangers ===")
	for i in num_rays:
		
		var PhysicsRayQuery := PhysicsRayQueryParameters2D.new()
		PhysicsRayQuery.from = global_position
		PhysicsRayQuery.to = global_position + ray_directions[i].rotated(rotation) * look_ahead
		PhysicsRayQuery.exclude = [self]
		PhysicsRayQuery.collision_mask = 0b11111111
		var result := space_state.intersect_ray(PhysicsRayQuery)
		danger[i] = (1.0 if result else 0.0) * 5
		#print("Direction: ", ray_directions[i].rotated(rotation))
		#print("Intersect: ", i, " ", result)
	#print("=== end ===")

func choose_direction() -> void:
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = -danger[i]
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO
	print("=== Choosen directions ===")
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
		print(ray_directions[i] * interest[i])
	print("Final: ", chosen_dir.normalized())
	print("=== end ===")
	chosen_dir = chosen_dir.normalized()
	

