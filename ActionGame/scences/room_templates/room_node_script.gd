extends Node2D
class_name RoomNode


var enemy_scene : = preload("res://scences/entities/enemy_melee.tscn") as PackedScene
var exit_scene := preload("res://scences/room_templates/exit_area.tscn") as PackedScene
enum {TOP = 1, BOT = 2, LEFT = 3, RIGHT = 4}
var available_doors: Array[int] = [TOP, BOT, LEFT, RIGHT]
var connected_doors: Array[int] = []
signal room_exited(from_side: int, to_room: int)

enum type {Enemy = 0b000, Special = 0b001, Shop = 0b010, Exit = 0b011, Start = 0b100}
var room_type: type = type.Enemy


func _ready() -> void:
	for exit: RoomExit in $Exits.get_children():
		exit.enter_room.connect(_on_room_enter)
		exit.exit_room.connect(_on_room_exit)


func connect_door_to_room(exit_side: int, connected_room: RoomNode) -> void:
	var room_exit: RoomExit = $Exits.get_child(exit_side - 1) as RoomExit
	
	# Get entrance of connected_room based on exit side
	var connected_entrance: RoomExit
	match exit_side:
		TOP:
			connected_entrance = connected_room.get_node("Exits").get_child(BOT - 1)
			connected_room.connected_doors.append(BOT)
			connected_room.available_doors.erase(BOT)
		BOT:
			connected_entrance = connected_room.get_node("Exits").get_child(TOP - 1)
			connected_room.connected_doors.append(TOP)
			connected_room.available_doors.erase(TOP)
		LEFT:
			connected_entrance = connected_room.get_node("Exits").get_child(RIGHT - 1)
			connected_room.connected_doors.append(RIGHT)
			connected_room.available_doors.erase(RIGHT)
		RIGHT:
			connected_entrance = connected_room.get_node("Exits").get_child(LEFT - 1)
			connected_room.connected_doors.append(LEFT)
			connected_room.available_doors.erase(LEFT)
		_:
			print("Invalid side")
			return
	
	# Connecting exit to connected_room entrance and vice-versa
	room_exit.connected_room = connected_room
	connected_entrance.connected_room = self
	
	# change the monitoring status of exits
	connected_doors.append(exit_side)
	available_doors.erase(exit_side)
	
	# disable the cover-wall
	connected_room.display_doors()
	display_doors()


func _on_room_exit() -> void:
	#room_exited.emit(from_side, to_room)
	pass
	
	
func _on_room_enter() -> void:
	pass


func display_doors() -> void:
	for i in connected_doors:
		($CoverWalls.get_child(i - 1) as Sprite2D).visible = false


func get_connected_room(exit_index: int) -> RoomNode:
	if connected_doors.size() == 0:
		return null
	
	if !connected_doors.has(exit_index):
		print("Door {"+str(exit_index)+"} is not connected.")
		return null
	
	var exit := $Exits.get_child(exit_index - 1) as RoomExit
	return exit.connected_room


func set_up_room() -> void:
	$CheckArea.queue_free()
	#for door_index in available_doors:
		#$Exits.get_child(door_index - 1).queue_free()
	
	match room_type:
		type.Enemy:
			spawn_enemies()
			pass
		type.Special:
			
			pass
		type.Shop:
			
			pass
		type.Exit:
			var exit := exit_scene.instantiate() as ExitArea
			add_child(exit)
		type.Start:
			
			pass


func spawn_enemies() -> void:
	var amount := randi_range(4, 10)
	
	var spawn_points := $SpawnPoints.get_children()
	for index in range(0, amount, 1):
		var enemy: EnemyMelee = enemy_scene.instantiate() as EnemyMelee
		#enemy.is_dead = true
		add_child(enemy)
		enemy.global_position = spawn_points[index].global_position
		enemy.target_position = enemy.global_position
