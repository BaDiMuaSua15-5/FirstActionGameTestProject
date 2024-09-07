extends Node2D
class_name DashEffect

var sprite: AnimatedSprite2D
var direction: Vector2

func _ready() -> void:
	ghosting()

func set_property(txt_pos: Vector2, txt_scale: Vector2, movement_direction: Vector2) -> void:
	scale = txt_scale
	position = txt_pos
	direction = movement_direction
	
func ghosting() -> void:
	($GPUParticles2D.process_material as ParticleProcessMaterial).direction = Vector3(direction.x, 0, 0)
	$GPUParticles2D.emitting = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.75)
	
	await tween.finished
	queue_free()
