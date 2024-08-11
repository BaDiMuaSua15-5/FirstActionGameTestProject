extends Node2D
class_name State

@onready var debug := owner.find_child("debug")
@onready var animation_player: AnimationPlayer
var StateMachine: FiniteStateMachine

func _ready() -> void:
	StateMachine = get_parent()
	if !StateMachine:
		print("Did not found State Machine parent, ", self)
		return
	
	set_physics_process(false)

func enter() -> void:
#	print(str(name) + 'enter')
	set_physics_process(true)

func exit() -> void:
#	print(str(name) + 'exit')
	set_physics_process(false)

func transition(delta: float) -> void:
	print("State: transition() not implemented")
	pass
	
func _physics_process(delta: float) -> void:
	transition(delta)
#	print(name)
	debug.text = name
	
	
