extends State

var player_near: bool = false

func enter():
	super.enter()
	player_near = false
	%WeaponComponent.weapon_unready()

func transition():
	if (player_near):
		get_parent().change_state("Pursuit")

func _on_notice_area_2d_body_entered(body):
	if body is PlayerObj:
		player_near = true
		owner.player = body
		print(owner.player.name)
