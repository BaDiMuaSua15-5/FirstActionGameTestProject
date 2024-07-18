extends Area2D
class_name HitBoxComponent

@export var health_component: Node
@export var owner_hypo: PhysicsBody2D

signal hitted

func hit(attack: AttackObj):
	health_component.health -= attack.damage
	print(health_component.health)
	hitted.emit(attack as AttackObj)
