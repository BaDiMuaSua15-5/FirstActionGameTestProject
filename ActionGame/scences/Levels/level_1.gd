extends Node2D

func _ready() -> void:
	Global.player_hit_sound = ($Sound/HitSound as AudioStreamPlayer2D)
	Global.throwable_break_sound = ($Sound/ThrowBreakSound as AudioStreamPlayer2D)
	Global.throwable_collide_sound = $Sound/ThrowCollideSound as AudioStreamPlayer2D
	Global.player = $ControlledChar
	Global.camera = $ControlledChar/Shakeable_Camera as ShakeableCamera
