extends StaticBody2D
class_name ChestWooden

@onready var Audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var health_comp := $HealthComponent as PlayerHealthComponent
var is_opened: bool = false

func _ready() -> void:
	$Label.visible = false
	$HitBoxComponent
	health_comp.health_depleted.connect(open)


func hitted(attack: AttackObj) -> void:
	if attack.Attacker is PlayerObj:
		Audio.pitch_scale = randf_range(1.25, 1.40)
		Audio.play()
		$Sprite2D.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_accept"):
		if !is_opened:
			open()


func open() -> void:
	is_opened = true
	$Sprite2D.visible = false
	$Label.visible = false
	Audio.pitch_scale = randf_range(1.25, 1.40)
	Audio.play()


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is PlayerObj && !is_opened:
		$Label.visible = true


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is PlayerObj && !is_opened:
		$Label.visible = false
