extends Node2D
class_name FiniteStateMachine

var current_state: State
var previous_state: State

func _ready() -> void:
	current_state = get_child(0)
	previous_state = current_state
	current_state.enter()

func change_state(new_state_name: String) -> void:
	#get desired state in FSM and set it to current_state
	current_state = find_child(new_state_name) as State
	if !current_state: # If can't find new state
		print("Could not found state: ", new_state_name)
		return
		
	#exit previous_state
	if current_state.name != previous_state.name: # If new state is different from previous
		# exit previous state
		previous_state.exit()
		
	# Enter new state
	current_state.enter()
	# Set new previous state for future references
	previous_state = current_state
	
	
