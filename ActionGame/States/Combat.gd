extends State

var in_attack: bool = true
var stunned: bool = false
var can_attack: bool = true
signal attack

func enter():
	super.enter()
	in_attack = true

func exit():
	super.exit()
#	if (stunned): 
#		stunned = false
#		%WeaponComponent.stop_attack()

func transition():
	if !in_attack:
		get_parent().change_state("Pursuit")
	if in_attack:
		if can_attack and $"../../WallDetectRay".get_collider() == null:
			%"Attack Timer".start()
			can_attack = false
			%WeaponComponent.attack()
			attack.emit()



func _on_stun_stunned():
	stunned = true
	
func _on_attack_area_body_exited(body):
	if body is PlayerObj:
		in_attack = false

func _on_attack_timer_timeout():
	can_attack = true
