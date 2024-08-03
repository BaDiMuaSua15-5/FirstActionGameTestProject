extends Node2D

var currentWeapon: Weapon_Resource
var weaponAnimPlayer: AnimationPlayer
signal attack_finished
signal attack_started

func _ready():
	currentWeapon = get_child(0).weapon_resource
	weaponAnimPlayer = get_child(0).animation_player
	get_child(0).connect("chain_atk", chain_attack)
	get_child(0).connect("animation_finished", _weapon_anim_player_finished)

func attack():
	if !weaponAnimPlayer.is_playing() and !owner.is_dead:
		weaponAnimPlayer.play(currentWeapon.Attack_Anim)
		attack_started.emit()

func _weapon_anim_player_finished(anim_name: String):
	if (anim_name.match(currentWeapon.Attack_Anim)):
		weaponAnimPlayer.play(currentWeapon.Recover_Anim)
		attack_finished.emit()

func chain_attack(attack_index: int):
	var choice
	if (attack_index < 1):
		choice = randf_range(3, 9)
	else:
		choice = randf_range(2, 9)
	if (choice<5):
		weaponAnimPlayer.play(currentWeapon.Recover_Anim)
		attack_finished.emit()
		return
	attack_started.emit()

func stop_attack():
	weaponAnimPlayer.stop()

func weapon_ready():
	if !weaponAnimPlayer.is_playing():
		weaponAnimPlayer.play(currentWeapon.Active_Anim)

func weapon_unready():
	if !(weaponAnimPlayer.is_playing()):
		weaponAnimPlayer.play(currentWeapon.Deactive_Anim)
