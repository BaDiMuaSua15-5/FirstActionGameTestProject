extends Node2D
class_name State

@onready var debug = owner.find_child("debug")
@onready var animation_player


func _ready():
	set_physics_process(false)

func enter():
#	print(str(name) + 'enter')
	set_physics_process(true)

func exit():
#	print(str(name) + 'exit')
	set_physics_process(false)

func transition():
	print("State: transition() not implemented")
	pass

func _physics_process(_delta):
	transition()
#	print(name)
	debug.text = name
	
	
