extends Sprite2D

var speed

var animationDelta = 0
var frame_time

func _ready():
	pass

func _process(delta):
	
	if (position.y < get_parent().position.y):
		position.y += speed*delta
	else:
		if(floor(animationDelta/frame_time) < hframes):
			set_frame(floor(animationDelta/frame_time))
			animationDelta += delta
		else:
			queue_free()
