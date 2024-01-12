extends CharacterBody2D

var state = "bouncing"

var zVelocity = -100
var gravity = 125

@onready var sprite = get_node("sprite")

func _physics_process(delta):
	print(sprite.position.y)
	print(zVelocity)
	match state:
		"bouncing":
			if sprite.position.y >= -1 && zVelocity > 0:
				sprite.position.y = -1
				if zVelocity >= -10:
					zVelocity = 0
					changeState("still")
				else:
					zVelocity = -0.7*zVelocity
			sprite.move_local_y(zVelocity*delta)
			zVelocity = zVelocity+gravity*delta
		"rolling":
			pass
		"still":
			pass
		"preserve":
			pass
		"serve":
			pass
	move_and_slide()

func changeState(desiredState):
	match state:
		"bouncing":
			pass
		"rolling":
			pass
		"still":
			pass
		"preserve":
			pass
		"serve":
			pass
	
	match desiredState:
		"bouncing":
			pass
		"rolling":
			pass
		"still":
			pass
		"preserve":
			pass
		"serve":
			pass
	
	state = desiredState
