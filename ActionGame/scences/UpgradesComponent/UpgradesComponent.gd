extends Node
class_name UpgradesComponent

@export var upgrades_container: Array[BaseUpgrade] = []

func get_upgrades() -> Array[BaseUpgrade]:
	return upgrades_container

func apply_attack_upgrades(attack: AttackObj) -> AttackObj:
	if upgrades_container.is_empty():
		return attack
	for upgrade in upgrades_container:
		if upgrade is BaseAttackUpgrade:
			upgrade.apply_upgrade(attack)
	
	return attack

func apply_speed_upgrade(speed: float) -> float:
	var final_speed := speed
	for upgrade in upgrades_container:
		if upgrade is MoveSpeedUpgrade:
			final_speed = upgrade.calculate_speed(final_speed)
	return final_speed

func apply_health_upgrade(max_health: float) -> float:
	var final_value := max_health
	for upgrade in upgrades_container:
		if upgrade is HealthMaxUpgrade:
			final_value = upgrade.apply_upgrade_(final_value)
	return final_value


func add_upgrade(added_upgrade: Resource) -> bool:
	for upgrade in upgrades_container:
		# If added_upgrade is same class
		if upgrade.is_class(added_upgrade.get_class()):
			# If upgrade tier is not maxed
			if upgrade.tier < upgrade.tier_max:
				upgrade.tier += 1
				return true
			# tier is maxed
			else:
				return false
	# if is not already exist, add to container
	upgrades_container.append(added_upgrade)
	return true

