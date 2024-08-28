extends Weapon

#@export var weapon_resource: Weapon_Resource
#@export var animation_player: AnimationPlayer
#@onready var WallRay: RayCast2D = $WallCheckRay
#var Character: CharacterBody2D

func _ready() -> void:
	WallRay = ($WallCheckRay as RayCast2D)
	WallRay.enabled = true
	animation_player.play("RESET")

func _physics_process(delta: float) -> void:
	WallRay.global_rotation = 0
	WallRay.position = global_position

func _on_ls_hitbox_area_entered(area: Area2D) -> void:
	if area is HitBoxComponent and area.owner != owner.owner:
		area = area as HitBoxComponent
		if !area:
			return
		print("Hitted", area.owner)
		
		var space_rid := get_world_2d().space
		var space_state := PhysicsServer2D.space_get_direct_state(space_rid)
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
		query.collision_mask = 0b0100
		query.exclude = [self]
		query.from = global_position
		query.to = area.global_position
		var wall_check_result := space_state.intersect_ray(query)
		
		if wall_check_result:
			print("Blocked by wall ", wall_check_result["collider"])
			return
		else:
			# Ignore if the hitted entity is in the group same as owner
			if area.owner.get_groups()[0] == ManagingComponent.owner.get_groups()[0]:
				print("Hitted Entity in same group")
				return
			else:
				print("Hit deal damage")
				var attack: AttackObj = AttackObj.new()
				attack.damage = weapon_resource.Damage
				attack.direction = Vector2(area.owner.global_position - owner.global_position).normalized()
				attack.knockback = weapon_resource.knockback
				attack.stun_time = weapon_resource.stun_time
				attack.Attacker = ManagingComponent.owner
				
				area.hit(attack)
	return


signal chain_atk
signal push_atk #Still waiting adding
signal finish_atk #Still waiting adding
signal animation_finished
@export var isAttacking: bool = false

func emit_chain_attack(index: int) -> void:
	chain_atk.emit(index)

#<Add function for sending signal after an attack part>
func emit_finish_attack() -> void:
	finish_atk.emit()
	
func emit_push_attack() -> void:
	push_atk.emit()
	#print('pushedd')
#==================================================

func _on_animation_player_animation_finished(anim_name: String) -> void:
	animation_finished.emit(anim_name)


func _on_ls_hitbox_body_entered(_body: PhysicsBody2D) -> void:
	pass
	
func play_weappon_sound() -> void:
	var audio_player := $AudioStreamPlayer2D as AudioStreamPlayer2D
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
