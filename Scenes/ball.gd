extends CharacterBody2D

var state = "bouncing"

var zVelocityPrev = 0
var zVelocity = -115
var gravity = 125

var netCollision = false

@onready var sprite = get_node("sprite")
@onready var ballHitBox = get_node("sprite/BallHitBox")
@onready var ballShadowHitBox = get_node("BallShadowHitBox")

func _ready():
	velocity = Vector2(5,25)

func _physics_process(delta):
	match state:
		"bouncing":
			if sprite.position.y >= -1 && zVelocity > 0:
				sprite.position.y = -1
				if abs(zVelocity) >= abs(zVelocityPrev) && zVelocityPrev != 0:
					zVelocity = 0
					changeState("still")
				else:
					velocity = velocity*0.9
					zVelocityPrev = zVelocity
					zVelocity = -0.7*zVelocity
			else:
				pass
			sprite.move_local_y(zVelocity*delta)
			zVelocity = zVelocity+gravity*delta
			move_and_slide()
		"rolling":
			pass
		"still":
			pass
		"preserve":
			pass
		"serve":
			pass

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

func _on_hit_box_area_entered(area):
	if ballShadowHitBox.has_overlapping_areas() && netCollision == false:
		netCollision = true
		if velocity.y  > 0 && position.y >= 32 || velocity.y < 0 && position.y <=33:
			velocity = velocity*0.5
			zVelocity = zVelocity*0.5
		else:
			velocity = velocity*-0.7

func _on_shadow_hit_box_area_entered(area):
	if area.get_name().contains("Racket") && sprite.position.y > -20:
		velocity = velocity*-2
		zVelocity = -50
		netCollision = false
		zVelocityPrev = 0
	if ballHitBox.has_overlapping_areas() && netCollision == false:
		netCollision = true
		if velocity.y  > 0 && position.y >= 31 || velocity.y < 0 && position.y <=33:
			velocity = velocity*0.5
			zVelocity = zVelocity*0.5
		else:
			velocity = velocity*-0.7
