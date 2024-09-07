extends StaticBody2D

@onready var Audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func hitted(attack: AttackObj) -> void:
	if attack.Attacker is PlayerObj:
		Audio.pitch_scale = randf_range(1.25, 1.40)
		Audio.play()
		$Sprite2D.visible = false

func _on_death() -> void:
	# do nothing
	pass
