extends Node2D
class_name RoomGenerator

var templates: RoomTemplates
var max_count: int = 11
var count: int = 0
var added_rooms: Array[RoomCell]

signal start_load
signal finish_load

var start_room := preload("res://scences/room_templates/room_starter.tscn")
var closed_top := preload("res://scences/room_templates/room_b.tscn")
var closed_bottom := preload("res://scences/room_templates/room_t.tscn")
var closed_left := preload("res://scences/room_templates/room_r.tscn")
var closed_right := preload("res://scences/room_templates/room_l.tscn")

func _ready() -> void:
	templates = get_node("Keep/RoomTemplates") as RoomTemplates
	count = 1
	#$Room_Start.start_spawn()
	$Keep/Timer.wait_time = 1.4
		
# function for child rooms to spawn in adjacent rooms
func spawn_room(at_position: Vector2, room_type: int, spawner: RoomCell) -> void:
	if count == max_count:
		print("Can't spawn mpre")
		return
	$Keep/Timer.stop()
	
	if !can_place_room(at_position):
		return
	
	var room: RoomCell = null
	if room_type == 1:
		var rand: int = randi_range(0, templates.bottom_door_rooms.size() - 1)
		room = templates.bottom_door_rooms[rand].instantiate()
	elif room_type == 2:
		var rand: int = randi_range(0, templates.top_door_rooms.size() - 1)
		room = templates.top_door_rooms[rand].instantiate()
	elif room_type == 3:
		var rand: int = randi_range(0, templates.right_door_rooms.size() - 1)
		room = templates.right_door_rooms[rand].instantiate()
	elif room_type == 4:
		var rand: int = randi_range(0, templates.left_door_rooms.size() - 1)
		room = templates.left_door_rooms[rand].instantiate()
	 
	count += 1
	room.spawn_caller = spawner
	added_rooms.append(room)
	add_child(room)
	room.global_position = at_position
	$Keep/Timer.start()
	
func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("dodge"):
		#regenerate()
	return

func regenerate() -> void:
	start_load.emit()
	added_rooms.clear()
	for child in get_children():
		if child is RoomCell:
			child.queue_free()
	await get_tree().create_timer(1).timeout
	count = 1
	var temp: RoomCell = start_room.instantiate() as RoomCell
	add_child(temp)
	return

func can_place_room(at_position: Vector2) -> bool:
	var space_rid := get_world_2d().space
	var space_state := PhysicsServer2D.space_get_direct_state(space_rid)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	query.hit_from_inside = true
	query.collision_mask = 0b00000000_00000000_00000001_00000000
	query.from = at_position
	query.to = at_position
	
	var wall_check_result := space_state.intersect_ray(query)
	if wall_check_result:
		return false
	print("Collide none: " + str(wall_check_result))
	return true

func process_opened_room() -> void:
	for room in added_rooms:
		var spawn_points := room.get_spawn_points()
		for sp in spawn_points:
			#if sp.has_obstruction == false:
			print("Spawn fix")
			spawn_closed_room(sp.global_position, sp.room_type)
	spawn_entities()

func spawn_entities() -> void:
	for room in added_rooms:
		room.spawn_in_entities()
	await get_tree().create_timer(3).timeout
	finish_load.emit()

func spawn_closed_room(at: Vector2, type: int) -> void:
	if !can_place_room(at):
		print("Cant fix")
		return
	print("fix")
	var temp: RoomCell
	match type:
		1:
			temp = closed_top.instantiate()
		2:
			temp = closed_bottom.instantiate()
		3:
			temp = closed_left.instantiate()
		4:
			temp = closed_right.instantiate()
	
	add_child(temp)
	temp.global_position = at
	

var success_count: int = 0
var total: int = 0
func _on_timer_timeout() -> void:
	if (count < max_count):
		total += 1
		regenerate()
		return
	
	total += 1
	success_count += 1
	process_opened_room()
	pass
	
