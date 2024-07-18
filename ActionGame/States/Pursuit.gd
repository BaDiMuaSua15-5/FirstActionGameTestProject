extends State

var player_near: bool = true
var in_attack: bool = false
@onready var locked_on: bool = false

func enter():
	super.enter()
	player_near = true
	#owner.set_physics_process(true)
	if !locked_on:
		%WeaponComponent.weapon_ready()
		locked_on = true

func exit():
	super.exit()
	#owner.set_physics_process(false)

func transition():
	if player_near == false:
		locked_on = false
		owner.player = null
		get_parent().change_state("Ide")
	if in_attack:
		get_parent().change_state("Combat")

func _on_notice_area_2d_body_exited(body):
	if body is PlayerObj:
		player_near = false

func _on_attack_area_body_exited(body):
	if body is PlayerObj:
		in_attack = false

func _on_attack_area_body_entered(body):
	if body is PlayerObj:
		in_attack = true
