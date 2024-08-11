extends Area2D

var contact: bool = false
var push_target: Node = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if contact:
		print('contacting')
	pass




func _on_area_exited(area: Area2D) -> void:
	contact = false

func _on_area_entered(area: Area2D) -> void:
	contact = true
