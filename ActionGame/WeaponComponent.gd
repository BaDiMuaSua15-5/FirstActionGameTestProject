extends Node2D
class_name WeaponComponent

var WeaponResource: Weapon_Resource
var weaponAnimPlayer: AnimationPlayer
var CurrentWeapon: Weapon
@export var equiped_weapon: int = 0
@export var Upgrades: UpgradesComponent
signal attack_finished
signal attack_started

func _ready() -> void:
	CurrentWeapon = get_child(equiped_weapon) as Weapon
	WeaponResource = CurrentWeapon.weapon_resource
	weaponAnimPlayer = CurrentWeapon.animation_player
	CurrentWeapon.connect("chain_atk", chain_attack)
	CurrentWeapon.connect("animation_finished", _weapon_anim_player_finished)


func attack() -> void:
	if !weaponAnimPlayer.is_playing() and !owner.is_dead:
		weaponAnimPlayer.play(WeaponResource.Attack_Anim)
		attack_started.emit()


func _weapon_anim_player_finished(anim_name: String) -> void:
	if (anim_name.match(WeaponResource.Attack_Anim)):
		weaponAnimPlayer.play(WeaponResource.Recover_Anim)
		attack_finished.emit()


func chain_attack(attack_index: int) -> void:
	var choice: int
	if (attack_index < 1):
		choice = randf_range(3, 9)
	else:
		choice = randf_range(2, 9)
	if (choice<5):
		weaponAnimPlayer.play(WeaponResource.Recover_Anim)
		attack_finished.emit()
		return
	attack_started.emit()


func stop_attack() -> void:
	#weaponAnimPlayer.stop(false)
	weaponAnimPlayer.call_deferred("stop", false)


func weapon_ready() -> void:
	if !weaponAnimPlayer.is_playing():
		weaponAnimPlayer.play(WeaponResource.Active_Anim)


func weapon_unready() -> void:
	if !(weaponAnimPlayer.is_playing()):
		weaponAnimPlayer.play(WeaponResource.Deactive_Anim)
