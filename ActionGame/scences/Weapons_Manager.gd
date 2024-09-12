extends Node2D
class_name WeaponsManager

var AnimPlayer: AnimationPlayer

var Current_Weapon: Weapon_Resource = null #Resource of current weapon

var Weapon_Stack: Array = [] #An String array of weapons' name held by player

var Weapon_Index: int= 0

var Next_Weapon: String #name of current weapon

var Weapon_List: Dictionary = {} #hashMap<String weapon_name, Weapon_Resource weapon> of Weapons that exist

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapons: Array[String]
@export var Upgrades: UpgradesComponent

@onready var ControlledChar: PlayerObj = self.get_parent()

func _ready() -> void:
	Initalize(Start_Weapons)
	for weapon: Weapon in $Weapons.get_children(false):
		weapon.connect("animation_finished", _on_animation_player_animation_finished)
		weapon.chain_atk.connect(chain_attack) #Signal for checking chain attack
		#weapon.connect("finish_atk", _on_weapon_finish_attack)
		weapon.push_atk.connect(ControlledChar._on_weapons_manager_push_signal)

func _input(event: InputEvent) -> void:
	if ControlledChar.is_dead || ControlledChar.in_knockback:
		return
	
	if event.is_action_pressed("switch weapon up"):
		Weapon_Index = min(Weapon_Index + 1, 1)
		exit(Weapon_Stack[Weapon_Index])
	if event.is_action_pressed("switch weapon down"):
		Weapon_Index = max(Weapon_Index - 1, 0)
		exit(Weapon_Stack[Weapon_Index])
		
	if event.is_action_pressed("attack"):
		if ControlledChar.StaminaComp.stamina > 0:
			attack()
	return

func Initalize(_start_weapons: Array) -> void:
	for weapon in _weapon_resources: #create and add weapon to a "dictionary" for future references
		Weapon_List[weapon.Weapon_Name] = weapon
	print(Weapon_List)
	
	for i: String in _start_weapons: #append weapons to the end of Weapon_Stack array	
		Weapon_Stack.push_back(i)
		
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	AnimPlayer = ($Weapons.get_node(Current_Weapon.Weapon_Name) as Weapon).animation_player
	enter()
	
func enter() -> void:
	AnimPlayer.queue(Current_Weapon.Active_Anim)

# function to add weapon to inventory
func add_weapon(weapon: Weapon_Resource) -> void:
	Weapon_List[weapon.Weapon_Name] = weapon
	Weapon_Stack.push_back(weapon.Weapon_Name)
	var WeaponIndex := Weapon_Stack.size() - 1
	exit(Weapon_Stack[WeaponIndex])

# exit - play Current_Weapon deactive animation 
# and set Next_Weapon string for usage in changeWeapon func
func exit(_next_weapon: String) -> void:
	if _next_weapon != Current_Weapon.Weapon_Name and !AnimPlayer.is_playing():
		#if AnimPlayer.get_current_animation() != Current_Weapon.Deactive_Anim:
		AnimPlayer.play(Current_Weapon.Deactive_Anim)
		Next_Weapon = _next_weapon

# set Current_Weapon based on weapon_name. 
# Getting Weapon resource by weapon_name
# then assign to Current_Weapon
func changeWeapon(weapon_name: String) -> void:
	Current_Weapon = Weapon_List[str(weapon_name)]
	AnimPlayer = ($Weapons.get_node(Current_Weapon.Weapon_Name)as Weapon).animation_player
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name: String) -> void:
	# Change weapon when deactive animation is finished
	if anim_name == Current_Weapon.Deactive_Anim:
		changeWeapon(Next_Weapon)
		return
		
	if anim_name == Current_Weapon.Attack_Anim:
		AnimPlayer.queue(Current_Weapon.Recover_Anim)
		isAttacking = false
		return

	if anim_name == Current_Weapon.Recover_Anim:
		#attack_finished.emit()
		ControlledChar._on_weapons_manager_attack_finished()
		return
		
	

# ATTACKING ----------
@export var isAttacking: bool = false
var attackChain: bool = false
signal attack_signal
signal attack_push
signal attack_finished

# Function for taking player's attack input
func attack() -> void:
	#check for timed chainAttack
	if (AnimPlayer.is_playing() and AnimPlayer.get_current_animation().match(Current_Weapon.Attack_Anim)): # Attack anim is playing
		if !($Weapons.get_node(Current_Weapon.Weapon_Name).isAttacking): # Not in attacking state
			#print("Chain attack")
			attackChain = true
	else: # Not in attack anim
		AnimPlayer.queue(Current_Weapon.Attack_Anim)
		isAttacking = true
		#attack_signal.emit()
		ControlledChar._on_weapons_manager_attack_signal()
		
func _on_weapon_finish_attack() -> void:
	pass

func _on_weapon_push_attack() -> void:
	#attack_push.emit()
	ControlledChar._on_weapons_manager_push_signal()
	pass

func chain_attack(_attack_index: int) -> void:
	if (attackChain): 
		attackChain = false
		#attack_signal.emit()
		ControlledChar._on_weapons_manager_attack_signal()
	elif Current_Weapon.Auto_Fire and Input.is_action_pressed("attack"):
		#attack_signal.emit()
		ControlledChar._on_weapons_manager_attack_signal()
	else:
		isAttacking = false
		AnimPlayer.play(Current_Weapon.Recover_Anim)


#func block() -> void:
	#pass


