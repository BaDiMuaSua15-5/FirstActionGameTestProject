extends State

var stun: bool = true
signal stunned

func enter():
	super.enter()
	stun = true
	%WeaponComponent.stop_attack()
	%StunTimer.start()
	#change colour when stunned
	owner.modulate = "ff0000"

func exit():
	super.exit()
	#change colour back
	owner.modulate = "ffffff"

func transition():
	if stun == false:
		get_parent().change_state("Pursuit")

func _on_stun_timer_timeout():
	stun = false
