extends State

func enter():
	super.enter()
	owner.set_physics_process(false)

func exit():
	super.exit()
	owner.set_physics_process(true)

func transition():
	await get_tree().create_timer(2).timeout
	get_parent().change_state("Ide")
