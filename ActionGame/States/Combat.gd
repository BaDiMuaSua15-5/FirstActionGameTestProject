extends State

@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

var in_attack_range: bool = true
var can_attack: bool = true
#signal attack

func enter() -> void:
	super.enter()
	in_attack_range = true

func exit() -> void:
	super.exit()

func transition(delta: float) -> void:
	player_track()
	
	if Entity.is_dead:
		StateMachine.change_state("Ide")
	
	if !in_attack_range || Entity.player == null:
		StateMachine.change_state("Pursuit")
	
	if can_attack && !Entity.wallRay.is_colliding(): # If there is no obsticle
		# Attack & disallow attack until the timer timeout
		WeaponComponent.attack()
		can_attack = false
		%"Attack Timer".start()
	return

func player_track() -> void:
	if Entity.player == null:
		#("Combat - No player")
		return
	#print("Combat - have player")
	var player_position := Entity.player.global_position
	Entity.target_pos = player_position

# The player is out of the attack range
func _on_attack_area_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		in_attack_range = false
	
# Force enemy to stop moving when is close to player
func _on_close_area_body_entered(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		Entity.speed_mult = 0

# Allow enemy to stop moving when not close to player
func _on_close_area_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		Entity.speed_mult = 1

# Enable attack when timer is timeout
func _on_attack_timer_timeout() -> void:
	can_attack = true
