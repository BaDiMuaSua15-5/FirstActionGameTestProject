extends Area2D

var contact: bool = false
var push_target = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if contact:
		print('contacting')
	pass




func _on_area_exited(area):
	contact = false

func _on_area_entered(area):
	contact = true
