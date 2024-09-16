extends Node2D
class_name State


@onready var animation_player: AnimationPlayer
var StateMachine: FiniteStateMachine

func _ready() -> void:
	StateMachine = get_parent()
	if !StateMachine:
		print("Did not found State Machine parent, ", self)
		return
	
	set_physics_process(false)

func enter() -> void:
	set_physics_process(true)

func exit() -> void:
	set_physics_process(false)

func transition_process(delta: float) -> void:
	print("State: transition_process() not implemented")
	pass

func transition_physics_process(delta: float) -> void:
	print("State: transition() not implemented")
	pass

	
	
