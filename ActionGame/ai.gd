extends CharacterBody2D

@onready var target: Node2D = $"../target"

var rotationSpeed = 2.0

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * 200

	move_and_slide()
	rotateToTarget(target, delta)

func rotateToTarget(target: Node2D, delta: float):
	var direction = (target.global_position - global_position).normalized()
	var angleTo = (-$MeshInstance2D.transform.y).angle_to(direction)
	$MeshInstance2D.rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))
	

