extends Node2D
class_name WeaponsManager

var AnimPlayer: AnimationPlayer

var Current_Weapon: Weapon_Resource = null #Resource of current weapon

var Weapon_Stack = [] #An String array of weapons' name held by player

var Weapon_Index = 0

var Next_Weapon: String #name of current weapon

var Weapon_List = {} #hashMap<String weapon_name, Weapon_Resource weapon> of Weapons that exist

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapon: Array[String]

func _ready():
	Initalize(Start_Weapon)
	for weapon in $Weapons.get_children(false):
		weapon.connect("animation_finished", _on_animation_player_animation_finished)
		weapon.chain_atk.connect(chain_attack) #Signal for checking chain attack
		#weapon.connect("finish_atk", _on_weapon_finish_attack)
		weapon.push_atk.connect(_on_weapon_push_attack)

func _input(event):
	if event.is_action_pressed("switch weapon up"):
		Weapon_Index = min(Weapon_Index + 1, 1)
		exit(Weapon_Stack[Weapon_Index])
	if event.is_action_pressed("switch weapon down"):
		Weapon_Index = max(Weapon_Index - 1, 0)
		exit(Weapon_Stack[Weapon_Index])

func Initalize(_start_weapons: Array):
	#create and add weapon to a "dictionary" for future references
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon
	print(Weapon_List)
	#append weapons to the end of Weapon_Stack array	
	for i in _start_weapons:
		Weapon_Stack.push_back(i) 
		
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	AnimPlayer = $Weapons.get_node(Current_Weapon.Weapon_Name).animation_player
	enter()
	
func enter():
	AnimPlayer.queue(Current_Weapon.Active_Anim)

func add_weapon(weapon: Weapon_Resource):
	Weapon_List[weapon.Weapon_Name] = weapon
	Weapon_Stack.push_back(weapon.Weapon_Name)
	var WeaponIndex = Weapon_Stack.size()-1
	exit(Weapon_Stack[WeaponIndex])

# exit - play Current_Weapon deactive animation 
# and set Next_Weapon string for usage in changeWeapon func
func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Weapon_Name and !AnimPlayer.is_playing():
		if AnimPlayer.get_current_animation() != Current_Weapon.Deactive_Anim:
			AnimPlayer.play(Current_Weapon.Deactive_Anim)
			Next_Weapon = _next_weapon

# set Current_Weapon based on weapon_name
# . Getting Weapon resource by weapon_name
# then assign to Current_Weapon
func changeWeapon(weapon_name: String):
	Current_Weapon = Weapon_List[str(weapon_name)]
	AnimPlayer = $Weapons.get_node(Current_Weapon.Weapon_Name).animation_player
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name):
	# Change weapon when deactive animation is finished
	if anim_name == Current_Weapon.Deactive_Anim:
		changeWeapon(Next_Weapon)
		
	if anim_name == Current_Weapon.Attack_Anim:
		AnimPlayer.queue(Current_Weapon.Recover_Anim)
		isAttacking = false

	if anim_name == Current_Weapon.Recover_Anim:
		attack_finished.emit()
		
	

# ATTACKING ----------
@export var isAttacking: bool = false
var attackChain: bool = false
signal attack_signal
signal attack_push
signal attack_finished

# Function for taking player's attack input
func attack():
	#check for timed chainAttack
	if (AnimPlayer.is_playing() and AnimPlayer.get_current_animation().match(Current_Weapon.Attack_Anim)):
		if !($Weapons.get_node(Current_Weapon.Weapon_Name).isAttacking):
			print("Chain attack")
			attackChain = true
	else:
		AnimPlayer.queue(Current_Weapon.Attack_Anim)
		isAttacking = true
		attack_signal.emit()
		
func _on_weapon_finish_attack():
	pass

func _on_weapon_push_attack():
	attack_push.emit()
	pass

func chain_attack(_attack_index: int):
	if (attackChain):
		attackChain = false
		#AnimPlayer.play()
		attack_signal.emit()
	elif Current_Weapon.Auto_Fire and Input.is_action_pressed("attack"):
		#AnimPlayer.play()
		attack_signal.emit()
	else:
		isAttacking = false
		AnimPlayer.play(Current_Weapon.Recover_Anim)

func _on_controlled_char_pressed_attack():
	attack()

func block():
	pass


