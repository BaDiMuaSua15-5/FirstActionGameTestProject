extends State

var stun: bool = true
@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

func enter() -> void:
	super.enter()
	stun = true
	WeaponComponent.stop_attack()
	%StunTimer.start()
	#change colour when stunned
	Entity.modulate = "ff0000"

func exit() -> void:
	super.exit()
	#change colour back
	Entity.modulate = "ffffff"

func transition(delta: float) -> void:
	if stun == false:
		StateMachine.change_state("Pursuit")

func _on_stun_timer_timeout() -> void:
	stun = false
	WeaponComponent.weapon_ready()
	
