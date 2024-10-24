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


func get_attack() -> AttackObj:
	var attack := AttackObj.new()
	attack.damage = weapon_resource.Damage
	attack.ap_accumulation = weapon_resource.ap_accumalation
	attack.direction = Vector2.ZERO
	attack.knockback = weapon_resource.knockback
	attack.stun_time = weapon_resource.stun_time
	attack.Attacker = ManagingComponent.owner
	return attack


func _on_ls_hitbox_area_entered(area: Area2D) -> void:
	if area == null:
		return
	var hitbox := area as HitBoxComponent
	if !hitbox:
		return
	if area.owner != ManagingComponent.owner:
		# Ignore if the hitted entity is in the group same as owner
		if hitbox.owner.get_groups()[0].matchn(ManagingComponent.owner.get_groups()[0]):
			return
		
		var space_rid := get_world_2d().space
		var space_state := PhysicsServer2D.space_get_direct_state(space_rid)
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
		query.collision_mask = 0b0100
		query.exclude = [self, hitbox.owner]
		query.from = global_position
		query.to = hitbox.global_position
		var wall_check_result := space_state.intersect_ray(query)
		
		if wall_check_result:
			return
		else:
			var attack := get_attack()
			attack.direction = (hitbox.owner.global_position - ManagingComponent.global_position).normalized()
			var upgrades_comp := ManagingComponent.Upgrades as UpgradesComponent
			attack = upgrades_comp.apply_attack_upgrades(attack)
			
			hitbox.hit(attack)
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
#==================================================

func _on_animation_player_animation_finished(anim_name: String) -> void:
	animation_finished.emit(anim_name)

	
func play_weappon_sound() -> void:
	var audio_player := $AudioStreamPlayer2D as AudioStreamPlayer2D
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
	
func play_effect() -> void:
	$Effect/AnimatedSprite2D.play("new_animation")
	
func play_effect_poke() -> void:
	$Effect/AnimatedSprite2D.play("poke")
