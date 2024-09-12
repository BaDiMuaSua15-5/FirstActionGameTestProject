extends StaticBody2D
class_name RoomCell

var spawners: Array[RoomSpawner]
var spawn_caller: RoomCell
signal level_finished

var enemy_scene : = preload("res://enemy.tscn") as PackedScene
var exit_point := preload("res://scences/room_templates/exit_area.tscn") as PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func setup_room() -> void:
	clear_room_spawner()
	if spawn_type == 0:
		spawn_in_entities()
	elif spawn_type == 1:
		# Spawn in upgrade items
		var enemy: EnemyObj = enemy_scene.instantiate() as EnemyObj
		enemy.global_position = global_position
		add_child(enemy)
		pass
	elif spawn_type == 2:
		# Spawn in Exit
		var exit := exit_point.instantiate() as ExitArea
		add_child(exit)
		exit.exited.connect(emit_level_finished)

var remaining_entity: int = 0
var spawn_type: int = 0
# 0 -> Spawn Enemies
# 1 -> Spawn Items
# 2 -> Spawn Exit
func spawn_in_entities() -> void:
	var positions: Array[Vector2] = [Vector2(-176, 176),
									Vector2(176, 176),
									Vector2(-176, -176),
									Vector2(176, -176)]
	for pos: Vector2 in positions:
		#var rand := randf_range(0, 1.0)
		#if rand <= 0.5:
			#continue
		var enemy: EnemyObj = enemy_scene.instantiate() as EnemyObj
		add_child(enemy)
		pos = pos * 4
		remaining_entity += 1
		
		enemy.died.connect(_on_entity_death)
		enemy.global_position = global_position + pos
		enemy.set_deferred("origin_pos", global_position + pos)
		enemy.set_deferred("target_pos", global_position + pos)
		
		var wanted_look_pos := global_position + Vector2(pos.x, -pos.y) 
		var wanted_look_dir := wanted_look_pos - (global_position + pos)
		var angle_to := (-enemy.transform.y).angle_to(wanted_look_dir)
		enemy.origin_rotation_vector = wanted_look_dir
		enemy.rotate(angle_to)

func clear_room_spawner() -> void:
	for spawner in get_children():
		if spawner.is_in_group("room_spawner"):
			spawner.queue_free()

func _on_entity_death() -> void:
	remaining_entity -= 1
	if remaining_entity == 0:
		print("Room cleared")
		
func emit_level_finished() -> void:
	level_finished.emit()
