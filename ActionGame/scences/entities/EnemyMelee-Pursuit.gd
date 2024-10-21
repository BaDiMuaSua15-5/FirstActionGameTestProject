extends State

@export var Entity: EnemyMelee
var combat_range: float = 650

func enter() -> void:
	super.enter()

func exit() -> void:
	super.exit()

func transition_process(delta: float) -> void:
	if Entity.is_dead:
		return
	pass

func transition_physics_process(delta: float) -> void:
	if Entity.is_dead:
		return
	if Entity.player == null:
		StateMachine.change_state("Idle")
		return
	
	
	var player_pos := Entity.player.global_position
	Entity.target_position = player_pos
	var dist_to_player := (player_pos - Entity.global_position).length()
	if dist_to_player <= combat_range:
		StateMachine.change_state("Combat")
		return
	
	
