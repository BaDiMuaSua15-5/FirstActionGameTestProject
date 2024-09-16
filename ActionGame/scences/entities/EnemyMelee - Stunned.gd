extends State

@export var Entity: EnemyMelee
@export var WeaponComponent: WeaponComponent

func enter() -> void:
	super.enter()
	WeaponComponent.stop_attack()

func exit() -> void:
	super.exit()

func transition_process(delta: float) -> void:
	if Entity.in_knockback == false:
		StateMachine.change_state("Pursuit")
		return
	
	if Entity.in_knockback:
		if Entity.knockback_time > 0:
			Entity.knockback_time -= delta
		else:
			Entity.speed_mult = 1
			Entity.in_knockback = false
	

func transition_physics_process(delta: float) -> void:
	pass


