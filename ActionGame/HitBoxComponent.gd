extends Area2D
class_name HitBoxComponent

@export var health_component: Node
@export var owner_hypo: PhysicsBody2D

signal hitted

func hit(attack: AttackObj):
	print('hitted hitbox')
	health_component.health -= attack.damage
	owner_hypo.damage(attack)
