extends Node2D

@export var weapon_resource: Weapon_Resource
@export var animation_player: AnimationPlayer

func _ready():
	animation_player.play("RESET")
	print(weapon_resource.Auto_Fire)

func _on_ls_hitbox_area_entered(area):
	if area is HitBoxComponent and area.owner != owner.owner:
		var attack: AttackObj = AttackObj.new()
		attack.damage = weapon_resource.Damage
		attack.direction = Vector2(area.owner.global_position - owner.global_position).normalized()
		attack.knockback = weapon_resource.knockback
		attack.stun_time = weapon_resource.stun_time
		area.hit(attack)



signal chain_atk
signal push_atk #Still waiting adding
signal finish_atk #Still waiting adding
signal animation_finished
@export var isAttacking: bool = false

func emit_chain_attack(index: int):
	chain_atk.emit(index)

#Add function for sending signal after an attack part
func emit_finish_attack():
	finish_atk.emit()
	
func emit_push_attack():
	push_atk.emit()
#==================================================

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)


func _on_ls_hitbox_body_entered(_body):
	animation_player.play(weapon_resource.Active_Anim)
	animation_finished.emit(weapon_resource.Attack_Anim)
