extends Area2D
class_name RoomSpawner


@export var room_type: int = 0
# 1 -> room with bottom door
# 2 -> room with top door
# 3 -> room with right door
# 4 -> room with left door
var has_obstruction: bool = false
var spawned: bool = false
var spawn_timer: float = 0.1

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	spawn_room()
	pass

#func _process(delta: float) -> void:
	#if spawn_timer > 0.0:
		#spawn_timer -= delta
		#return
	#spawn_room()

func spawn_room() -> void:
	if room_type == 0 || spawned:
		return
	
		
	spawned = true
	var generator := get_parent().get_parent() as RoomGenerator
	generator.spawn_room(global_position, room_type, get_parent())
	

func _on_area_entered(area: Area2D) -> void:
	has_obstruction = true
	if area.spawned == false && spawned == false:
		area.spawned = true

func _on_body_entered(body: Node2D) -> void:
	has_obstruction = true
	spawned = true
