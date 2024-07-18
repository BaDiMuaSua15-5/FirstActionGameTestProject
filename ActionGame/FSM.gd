extends Node2D

@onready var animation_player: AnimationPlayer = %WeaponComponent.weaponAnimPlayer
var current_state: State
var previous_state: State

func _ready():
	current_state = get_child(0)
	previous_state = current_state
	current_state.enter()

func change_state(state):
	#get desired state in FSM and set it to current_state
	current_state = find_child(state) as State
	
	#exit previous_state
	if (current_state.name != previous_state.name):
		previous_state.exit()
	
	current_state.enter()
	previous_state = current_state
	
	
