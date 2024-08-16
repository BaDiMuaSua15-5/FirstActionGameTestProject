extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var timer_label: Label = $Status/MarginContainer/VBoxContainer/Label
@onready var health_label: Label = $Status/MarginContainer/VBoxContainer/HealthBar/Label
@export var Player: PlayerObj
var StaminaRegenTimer: Timer
var HealthCmp: PlayerHealthComponent
var StaminaCmp: StaminaComponent

func _ready() -> void:
	if Player:
		HealthCmp = Player.find_child("HealthComponent")
		StaminaCmp = Player.find_child("StaminaComponent")
		StaminaRegenTimer = Player.find_child("StaminaComponent").get_child(0)
	HealthCmp.connect("health_change", update_health_bar)
	StaminaCmp.connect("stamina_change", update_stamina_bar)
	update_health_bar(HealthCmp.health, HealthCmp.max_health)

func _process(delta: float) -> void:
	timer_label.text = "Timer: "+str(StaminaRegenTimer.time_left)
	pass

func update_health_bar(health_value: int, max_value: int) -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = max_value + 0.0
	health_bar.value = health_value + 0.0
	
	health_label.text = str(health_value) + "/" + str(max_value)
  
func update_stamina_bar(stamina_value: float, max_value: float) -> void:
	stamina_bar.value = stamina_value
	stamina_bar.max_value = max_value

func update_stat() -> void:
	pass
