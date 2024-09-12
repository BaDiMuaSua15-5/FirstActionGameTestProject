extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var timer_label: Label = $Status/HSplitContainer/StatusDisplay/Timer
@onready var health_label: Label = $Status/HSplitContainer/StatusDisplay/HealthBar/Label
@onready var AP_counter: Label = $Status/HSplitContainer/HSplitContainer/ActionPointDisplay/ActionPointCounter
@onready var AP_bar: ProgressBar = $Status/HSplitContainer/HSplitContainer/ProgressBar
@export var Player: PlayerObj
var StaminaRegenTimer: Timer
var HealthCmp: PlayerHealthComponent
var StaminaCmp: StaminaComponent
var APComp: APComponent

func _ready() -> void:
	if Player:
		HealthCmp = Player.find_child("HealthComponent")
		StaminaCmp = Player.find_child("StaminaComponent")
		StaminaRegenTimer = Player.find_child("StaminaComponent").get_child(0)
		APComp = Player.find_child("APComponent") as APComponent
	HealthCmp.health_change.connect(update_health_bar)
	StaminaCmp.stamina_change.connect(update_stamina_bar)
	APComp.ap_change.connect(update_ap_display)
	update_health_bar(HealthCmp.health, HealthCmp.max_health)
	update_ap_display(APComp.fill_progress, APComp.ap_count)
	
	
func _process(delta: float) -> void:
	#if Player:
		#timer_label.text = "Timer: "+str(StaminaRegenTimer.time_left)
	pass

func update_health_bar(health_value: int, max_value: int) -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = max_value + 0.0
	print("Max health: ", max_value)
	var tween := get_tree().create_tween()
	tween.tween_property(health_bar, "value", health_value + 0.0, 0.5)
	
	health_label.text = str(health_value) + "/" + str(max_value)
  
func update_stamina_bar(stamina_value: float, max_value: float) -> void:
	stamina_bar.value = stamina_value
	stamina_bar.max_value = max_value

func update_ap_display(progress: int, ap_count: int) -> void:
	AP_counter.text = str(ap_count)
	print("Fill progres: ", APComp.fill_progress)
	print("Fill max: ", APComp.max_progress)
	print("Fill percent: ", APComp.fill_progress + 0.0 / APComp.max_progress)
	AP_bar.value = APComp.fill_progress + 0.0 / APComp.max_progress

func update_stat() -> void:
	pass
