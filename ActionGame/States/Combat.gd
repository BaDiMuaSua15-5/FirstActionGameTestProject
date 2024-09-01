extends State

@export var Entity: EnemyObj
@export var WeaponComponent: WeaponComponent

var in_attack_range: bool = true
var can_attack: bool = true
var queue_attack_time: float
#signal attack

func enter() -> void:
	super.enter()
	in_attack_range = true
	can_attack = true
	Entity.in_combat = true
	
func exit() -> void:
	super.exit()
	Entity.in_combat = false
	Entity.player.call_deferred("_on_attacker_dequeue", get_instance_id())

func transition(delta: float) -> void:
	player_track()
	
	if Entity.is_dead:
		StateMachine.change_state("Ide")
		return
	
	if !in_attack_range || Entity.player == null:
		StateMachine.change_state("Pursuit")
	
	if can_attack && !Entity.wallRay.is_colliding(): # If there is no obsticle
		if Entity.player.attacker_in_queue(get_instance_id()) == true:
			can_attack = false
			%"Attack Timer".wait_time = 3
			%"Attack Timer".start()
		else:
			Entity.player._on_attacker_queue(get_instance_id())
	
	return

func player_track() -> void:
	if Entity.player == null:
		#print("Combat - No player")
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
	#if body is PlayerObj:
		#Entity.speed_mult = 0
	return

# Allow enemy to stop moving when not close to player
func _on_close_area_body_exited(body: PhysicsBody2D) -> void:
	if body is PlayerObj:
		Entity.speed_mult = 1

# Enable attack when timer is timeout
func _on_attack_timer_timeout() -> void:
	WeaponComponent.attack()
	if Entity.player:
		Entity.player._on_attacker_dequeue(get_instance_id())
	await get_tree().create_timer(%"Attack Timer".wait_time).timeout
	can_attack = true
