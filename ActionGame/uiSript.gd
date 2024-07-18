extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var timer_label: Label = $Status/MarginContainer/VBoxContainer/Label
@export var Player: PlayerObj
var timer: Timer
var HealthCmp: PlayerHealthComponent
var StaminaCmp: StaminaComponent

func _ready():
	HealthCmp = Player.find_child("HealthComponent")
	StaminaCmp = Player.find_child("StaminaComponent")
	timer = Player.find_child("StaminaComponent").get_child(0)
	HealthCmp.connect("health_change", update_health_bar)
	StaminaCmp.connect("stamina_change", update_stamina_bar)
	update_health_bar(HealthCmp.health, HealthCmp.max_health)

func _process(delta):
	timer_label.text = "Timer: "+str(timer.time_left)

func update_health_bar(health_value, max_value):
	health_bar.value = health_value
	health_bar.max_value = max_value
  
func update_stamina_bar(stamina_value, max_value):
	stamina_bar.value = stamina_value
	stamina_bar.max_value = max_value

func update_stat() -> void:
	pass
