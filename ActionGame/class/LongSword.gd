extends Node2D

@export var weapon_resource: Weapon_Resource
@export var animation_player: AnimationPlayer
@onready var WallRay: RayCast2D = $WallCheckRay
var Character: CharacterBody2D

func _ready():
	animation_player.play("RESET")
	print(weapon_resource.Auto_Fire)
	var owner_test = owner
	print('ownertest: ',owner_test)
	print(get_tree().get_node_count())

func _physics_process(delta):
	WallRay.global_rotation = 0

func _on_ls_hitbox_area_entered(area):
	if area is HitBoxComponent and area.owner != owner.owner:
		#(Character.WallChecker as RayCast2D).target_position = area.global_position - owner.global_position
		WallRay.target_position = area.global_position - owner.global_position
		#await (Character.WallChecker as RayCast2D).draw
		await (WallRay as RayCast2D).draw
		print("Area owner position: ", area.global_position)
		
		if WallRay.is_colliding():
			print("Wall collide")
			return
		else:
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

#<Add function for sending signal after an attack part>
func emit_finish_attack():
	finish_atk.emit()
	
func emit_push_attack():
	push_atk.emit()
	print('pushedd')
#==================================================

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)


func _on_ls_hitbox_body_entered(_body):
	#animation_player.play(weapon_resource.Active_Anim)
	#animation_finished.emit(weapon_resource.Attack_Anim)
	pass
