extends Node

var is_dragging: bool = false
var is_on_draggable: bool = false

var player_hit_sound: AudioStreamPlayer2D
var throwable_break_sound: AudioStreamPlayer2D
var throwable_collide_sound: AudioStreamPlayer2D
var player: PlayerObj
var camera: ShakeableCamera

func hitstop_effect(time_scale:float, duration: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0

func _ready() -> void:
	return

func play_hit_sound() -> void:
	if player_hit_sound == null:
		return
	if player:
		player_hit_sound.global_position = player.position
	player_hit_sound.pitch_scale = randf_range(0.65, 0.8)
	player_hit_sound.play()

func play_throw_break_sound() -> void:
	if throwable_break_sound == null:
		return
	if player:
		throwable_break_sound.global_position = player.position
	throwable_break_sound.pitch_scale = randf_range(0.9, 1.1)
	throwable_break_sound.play()

func play_throw_collide_sound() -> void:
	if throwable_collide_sound == null:
		return
	if player:
		throwable_collide_sound.global_position = player.position
	throwable_collide_sound.pitch_scale = randf_range(0.7, 0.9)
	throwable_collide_sound.play()
