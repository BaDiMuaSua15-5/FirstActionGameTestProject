# DESCRIPTION
#
#  This is a simple Godot game that lets you move a sprite around in two ways:
#
#     * by clicking, and then without moving, releasing. Then you can drag
#       the sprite around without holding down the mouse button. When you
#       want to drop the sprite, release the mouse button.
#
#     * by clicking, and then while holding the mouse button down, dragging
#       the sprite to where you want it by moving the mouse. When you want
#       to drop the sprite, release the mouse.
#

# RUN THIS CODE
#
# To run this code, just open Godot, create a Sprite, load icon.png from the
# the FileSystem tab into your Sprite, name your Sprite, attach an empty script
# to your Sprite, drop this code into it, save, and run.

# This line of code is what lets you use methods and properties Sprite has,
# like set_process_input, and global_position.
extends Sprite2D

# Define the status of the sprite: "none", "clicked", "released", or "dragging".
var status = "none"

# Define the vector that will contain the (width, height) of the sprite
var tsize = Vector2()

# Define the mouse position.
var mpos = Vector2()

# The is one of Godot's "hooks" or "callbacks" - a function called at a certain
# time in another program's execution. You can search for the functions that
# start with an underscore "_" in the Godot documentation online. This function
# gets called whenever your sprite enters the scene tree.
func _ready():
	tsize = get_texture().get_size()
	print(tsize)
	
	# Set the initial global position of the sprite to be the center of the
	# viewport. Note GDScript supports vector math.
	global_position = get_viewport_rect().size / 2

# This is another Godot hook. It is called every single frame!
func _process(delta):
	# If the sprite is being dragged in either of the two modes, update its
	# position every frame. To update the position, we use the position of
	# the mouse, plus an offset. The offset is the vector pointing from the
	# last mouse event's position to the current global_position of the sprite.
	if status == "dragging":
		global_position = get_global_mouse_position() - offset

# Yet another Godot hook. It is called every time an input event @ev is
# received. The input events we care about are clicks (InputEventMouseButton)
# and movement (InputEventMouseButton). We do something special for each event,
# in order control the state of the game. No matter what, every time this
# hook is called, we update the mouse position to match the position at which
# the input event was generated.
func _input(event):
	# This is the Godot 3.1.5 way to check event type. There is no longer a
	# "type" property on @ev. That's going to break a lot of people's code...
	#
	# If the event is for a left-button click, do things.
	if event.is_action("mouse_click"):
		# If the sprite is not being dragged, and if the mouse button was
		# clicked (as opposed to released, or "unclicked"), do things.
		if status != "dragging" and event.pressed:
			# Define a event position variable (scoped to this if block)
			var evpos = event.global_position
			
			# Define a global sprite position variable (scoped to this if
			# block)
			var gpos = global_position
			
			# The Sprite can be centered or not, and this can change during
			# the game. That's why we check for it in the loop. We are creating
			# a rect with the sprites dimensions and position in order to
			# check if the sprite was clicked or not, so it's important to
			# know whether or not the sprite is centered!
			var rect = Rect2()
			if is_centered():
				# If the sprite is centered, be sure to switch the x and y
				# coordinates of the position by half the width and half the
				# height of the sprite, respectively.
				rect = Rect2(gpos.x - tsize.x / 2, gpos.y - tsize.y / 2, tsize.x, tsize.y)
			else:
				# If the sprite is not centered, no need to shift the
				# coordinates. We can just use the sprite's global position
				# by itself.
				rect = Rect2(gpos.x, gpos.y, tsize.x, tsize.y)
				
			# This is where we actually check if the sprite was clicked or not,
			# by checking if the clicked point is in the Sprite's rectangle.
			if rect.has_point(evpos):
				# If the sprite's rectangle was clicked, update the sprite
				# status to "clicked", and update the offset. The offset is
				# the vector pointing from @evpos to @gpos.
				status = "clicked"
				offset = evpos - gpos
		
		# If the sprite is being dragged and the mouse button is being released,
		# set the sprite status to "released" to stop dragging and drop the
		# sprite.
		elif status == "dragging" and event.is_action_released("mouse_click"):
			status = "released"
	
	# If the card status is "clicked" and the mouse is being moved, set the
	# sprite status to "dragging", so the appropriate loop can run when a mouse
	# button click or release event is next received.
	if status == "clicked" and event is InputEventMouseMotion:
		status = "dragging"

	# Not matter what, every time an input event is received, update the mouse
	# position with the event's global position. This may need to be moved
	# into the other "if" statements when we start handling other input events
	# here.
	mpos = event.global_position


func _on_character_body_2d_mouse_entered():
	print("Enter")