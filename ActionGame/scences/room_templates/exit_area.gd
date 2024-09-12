extends Area2D
class_name ExitArea

signal exited
var recieve_input: bool = false

func _ready() -> void:
	%Label.visible = false
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerObj:
		print("player enter exit")
		recieve_input = true
		%Label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerObj:
		recieve_input = false
		%Label.visible = false

func _input(event: InputEvent) -> void:
	if !recieve_input:
		return
	if event.is_action("player_accept"):
		print("Exit level emited")
		exited.emit()
