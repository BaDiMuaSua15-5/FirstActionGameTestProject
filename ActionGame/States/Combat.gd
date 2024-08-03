extends State

var in_attack: bool = true
var can_attack: bool = true
signal attack

func enter():
	super.enter()
	in_attack = true

func exit():
	super.exit()

func transition():
	if !in_attack:
		get_parent().change_state("Pursuit")
	
	if can_attack && !(owner as EnemyObj).wallRay.is_colliding():
		%"Attack Timer".start()
		can_attack = false
		%WeaponComponent.attack()
		attack.emit()

func _on_attack_area_body_exited(body):
	if body is PlayerObj:
		in_attack = false

func _on_attack_timer_timeout():
	can_attack = true
