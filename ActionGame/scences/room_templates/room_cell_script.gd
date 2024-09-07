extends StaticBody2D
class_name RoomCell

var spawners: Array[RoomSpawner]
var spawn_caller: RoomCell

var enemy_scene : = preload("res://enemy.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(1).timeout
	#call_deferred("spawn_in_entities")
	return

func get_spawn_points() -> Array[RoomSpawner]:
	var result: Array[RoomSpawner]
	for spawner in get_children():
		if spawner.is_in_group("room_spawner"):
			result.append(spawner)
	if result.size() == 0:
		result.clear()
		return result
	return result
	
var remaining_entity: int = 0
func spawn_in_entities() -> void:
	clear_room_spawner()
	var positions: Array[Vector2] = [Vector2(-176, 176),
									Vector2(176, 176),
									Vector2(-176, -176),
									Vector2(176, -176)]
	#if $SpawnPoints == null:
		#return
	for pos: Vector2 in positions:
		#var rand := randf_range(0, 1.0)
		#if rand <= 0.5:
			#continue
		var enemy: EnemyObj = enemy_scene.instantiate() as EnemyObj
		add_child(enemy)
		remaining_entity += 1
		enemy.died.connect(_on_entity_death)
		enemy.global_position = global_position + pos * 2.5
		enemy.set_deferred("origin_pos", global_position + pos * 2.5)
		enemy.set_deferred("target_pos", global_position + pos * 2.5)

func clear_room_spawner() -> void:
	for spawner in get_children():
		if spawner.is_in_group("room_spawner"):
			spawner.queue_free()

func _on_entity_death() -> void:
	remaining_entity -= 1
	if remaining_entity == 0:
		print("Room cleared")
