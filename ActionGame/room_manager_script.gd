extends Node2D
class_name RoomManager

var room_template := preload("res://scences/room_templates/room_node_prototype2.tscn")
var enemy_template := preload("res://enemy.tscn")

var current_room: RoomNode
var placement_offset: Vector2
var main_rooms: Array[RoomNode]
var max_room_count: int = 10
var main_count: int = 6
var room_count: int = 0


func _ready() -> void:
	current_room = $Rooms/Room_Node as RoomNode
	placement_offset += Vector2(1824 * 2, 0)
	room_count += 1
	main_rooms.append(current_room)
	setup_level()

func setup_level() -> void:
	# Spawn in main rooms
	while room_count < main_count:
		await spawn_room()
		await get_tree().create_timer(0.1).timeout
	main_rooms[0].room_type = RoomNode.type.Start
	main_rooms[main_rooms.size() - 1].room_type = RoomNode.type.Exit
	main_rooms[-1].level_finished.connect(reset_level)
	$Camera2D2.global_position = (main_rooms[0].global_position - main_rooms[-1].global_position) / 2
	
	main_rooms.size()
	# select random room to branch out additional rooms
	var branch_amount := randi_range(1, 4) + room_count
	current_room = main_rooms[randi_range(0, 2)]
	while room_count < branch_amount:
		await spawn_room()
		await get_tree().create_timer(0.1).timeout
	
	current_room = main_rooms[randi_range(3, 4)]
	while room_count < max_room_count:
		await spawn_room()
		await get_tree().create_timer(0.1).timeout
		
	for index in range(1, main_rooms.size(), 1):
		main_rooms[index].set_up_room()
	
	
func spawn_room() -> void:
	# create new room
	var new_room := room_template.instantiate() as RoomNode
	$Rooms.add_child(new_room)
	main_rooms.append(new_room)
	room_count += 1
	#======While - Start======
	while true:
		if current_room.available_doors.size() == 0:
			var connected_room := current_room.get_connected_room(current_room.connected_doors.pick_random())
			current_room = connected_room
		# pick random side to place room
		var rand := current_room.available_doors.pick_random() as int
		# Place new room based on current room exit side
		var offset: Vector2
		var offset_amount: int = 1824 * 2
		match rand:
			current_room.TOP:
				offset = Vector2(0, -offset_amount)
			current_room.BOT:
				offset = Vector2(0, offset_amount)
			current_room.LEFT:
				offset = Vector2(-offset_amount, 0)
			current_room.RIGHT:
				offset = Vector2(offset_amount, 0)
		
		var existing_room := room_exist(current_room.position + offset)
		# If there is no room overlap
		if existing_room == null:
			new_room.global_position = current_room.global_position + offset
			current_room.connect_door_to_room(rand, new_room)
			break
		# else switch to connected room
		else:
			# Chose to connect the overlaping room to current room (random%)
			if randi_range(0, 2) >= 1:
				current_room.connect_door_to_room(rand, existing_room)
				current_room = existing_room
	#======While - End======
	current_room = new_room

# 
func room_exist(at_position: Vector2) -> RoomNode:
	var space_rid := get_world_2d().space
	var space_state := PhysicsServer2D.space_get_direct_state(space_rid)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	query.hit_from_inside = true
	query.collide_with_areas = true
	query.collision_mask = 0b00000000_00000000_00000001_00000000
	query.from = at_position
	query.to = at_position
	
	var wall_check_result := space_state.intersect_ray(query)
	if wall_check_result:
		return wall_check_result["collider"].get_parent()
	return null
	

func reset() -> void:
	var current_room: RoomNode
	var placement_offset: Vector2
	var main_rooms: Array[RoomNode]
	var max_room_count: int = 10
	var main_count: int = 6
	var room_count: int = 0
	
	
func reset_level() -> void:
	
	for i in range(1, main_rooms.size(), 1):
		main_rooms[i].queue_free()
	
	
	current_room = main_rooms[0]
	main_rooms.clear()
	main_rooms.append(current_room)
	current_room.connected_doors.clear()
	current_room.available_doors = [current_room.TOP, current_room.BOT, current_room.LEFT, current_room.RIGHT]
	room_count = 1
	await get_tree().create_timer(2).timeout
	Global.player.global_position = current_room.global_position
	call_deferred("setup_level")
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("function"):
		reset_level()
