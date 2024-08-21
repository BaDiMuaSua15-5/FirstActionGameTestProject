extends Weapon

#@export var weapon_resource: Weapon_Resource
#@export var animation_player: AnimationPlayer
#@onready var WallRay: RayCast2D = $WallCheckRay
#var Character: CharacterBody2D

func _ready() -> void:
	WallRay = $WallCheckRay
	
	animation_player.play("RESET")
	var owner_test := owner

func _physics_process(delta: float) -> void:
	WallRay.global_rotation = 0

func _on_ls_hitbox_area_entered(area: Area2D) -> void:
	if area is HitBoxComponent and area.owner != owner.owner:
		area = area as HitBoxComponent
		print("Hitted", area.owner)
		var target: Vector2 = (area.global_position - global_position).rotated(-global_rotation)
		WallRay.target_position = area.global_position - global_position
		#await (WallRay as RayCast2D).draw
		
		if area.has_method("hit"):
				print("Area has hit method")
		
		if WallRay.is_colliding():
			print("Collide ", WallRay.get_collider())
			return
		else:
			var attack: AttackObj = AttackObj.new()
			attack.damage = weapon_resource.Damage
			attack.direction = Vector2(area.owner.global_position - owner.global_position).normalized()
			attack.knockback = weapon_resource.knockback
			attack.stun_time = weapon_resource.stun_time
			
			area.hit(attack)
			
			#WallRay.enabled = false



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
