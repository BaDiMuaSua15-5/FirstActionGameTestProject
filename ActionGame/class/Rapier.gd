extends Node2D

@export var weapon_resource: Weapon_Resource
@export var animation_player: AnimationPlayer


func _on_rp_hitbox_area_entered(area):
	if area is HitBoxComponent and area.owner != owner.owner:
		var attack: AttackObj = AttackObj.new()
		attack.damage = weapon_resource.Damage
		attack.direction = Vector2(area.owner.global_position - owner.global_position).normalized()
		attack.knockback = weapon_resource.knockback
		attack.stun_time = weapon_resource.stun_time
		area.hit(attack)

signal chain_atk
signal animation_finished
@export var isAttacking: bool = false

func emit_chain_attack(index: int):
	chain_atk.emit(index)

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)
