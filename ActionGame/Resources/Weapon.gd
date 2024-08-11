extends Node2D
class_name Weapon

@export var weapon_resource: Weapon_Resource
@export var animation_player: AnimationPlayer
@onready var WallRay: RayCast2D
var Character: CharacterBody2D

func _ready() -> void:
	instantiate()

func instantiate() -> void:
	chain_attack(0)
	stop_attack()
	weapon_ready()
	weapon_unready()

func chain_attack(attack_index: int) -> void:
	print("chain_attack() function not implemented")
	
func stop_attack() -> void:
	print("stop_attack() function not implemented")

func weapon_ready() -> void:
	print("weapon_ready() function not implemented")
	
func weapon_unready() -> void:
	print("weapon_unready() function not implemented")
