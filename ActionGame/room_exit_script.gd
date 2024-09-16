extends Area2D
class_name RoomExit


enum side {TOP= 1, BOT= 2, LEFT= 3, RIGHT= 4, No=0}
@export var side_type: side = 0
var connected_room: RoomNode

var allow_exit: bool = false
signal enter_room
signal exit_room
var player: PlayerObj

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerObj && connected_room:
		allow_exit = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerObj && connected_room:
		allow_exit = false
		player = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_accept"):
		if allow_exit:
			var connected_entrance: RoomExit
			match side_type:
				side.TOP:
					connected_entrance = connected_room.get_node("Exits").get_child(side.BOT - 1)
				side.BOT:
					connected_entrance = connected_room.get_node("Exits").get_child(side.TOP - 1)
				side.LEFT:
					connected_entrance = connected_room.get_node("Exits").get_child(side.RIGHT - 1)
				side.RIGHT:
					connected_entrance = connected_room.get_node("Exits").get_child(side.LEFT - 1)
				_:
					return
			player.global_position = connected_entrance.get_child(0).global_position
			exit_room.emit()
			connected_entrance.enter_room.emit()
			allow_exit = false
			pass
