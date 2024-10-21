extends State

@export var Entity: EnemyMelee
@export var WeaponComp: WeaponComponent

var combat_range: float = 600
var can_atk: bool = false
var atk_between_time: float = 2.6

func enter() -> void:
	super.enter()
	Entity.in_combat = true

func exit() -> void:
	super.exit()
	Entity.in_combat = false

func transition_process(delta: float) -> void:
	if Entity.is_dead:
		return
	if can_atk == false:
		if atk_between_time > 0:
			atk_between_time -= delta
		else:
			$AnimationPlayer.play("attack_warn")
		return
		
	WeaponComp.attack()
	atk_between_time = randf_range(2.2, 2.6)
	can_atk = false

func transition_physics_process(delta: float) -> void:
	if Entity.is_dead:
		return
	if Entity.player == null:
		StateMachine.change_state("Idle")
		return
	
	var dist_to_player := (Entity.player.global_position - Entity.global_position).length()
	Entity.target_position = Entity.player.global_position
	if dist_to_player > combat_range:
		StateMachine.change_state("Pursuit")
		return
	
	
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	can_atk = true
