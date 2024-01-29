extends CharacterBody2D

var state = "bouncing"

var zVelocityPrev = 0
var zVelocity = -90
var gravity = 125
var friction = 20
var size = 4

var netCollision = false
var racketCollision = false

@onready var sprite = get_node("sprite")
@onready var ballHitBox = get_node("sprite/BallHitBox")
@onready var ballShadowHitBox = get_node("BallShadowHitBox")
@onready var player = get_node("AnimationPlayer")

func _ready():
	velocity = Vector2(-2,50)

func _physics_process(delta):
	match state:
		"bouncing":
			if sprite.position.y >= -1 && zVelocity > 0:
				sprite.position.y = -1
				if abs(zVelocity) >= abs(zVelocityPrev) && zVelocityPrev != 0:
					zVelocity = 0
					if velocity != Vector2.ZERO:
						changeState("roll")
					else:
						changeState("still")
				else:
					velocity = velocity*0.9
					zVelocityPrev = zVelocity
					zVelocity = -0.7*zVelocity
			else:
				pass
			sprite.move_local_y(zVelocity*delta)
			zVelocity = zVelocity+gravity*delta
			
			if sprite.position.y <= -70:
				size = 8
			elif sprite.position.y <= -35:
				size = 6
			else:
				size = 4
			player.set_speed_scale(velocity.length()/25)
			player.play(str(size)+vectorToString(velocity))
			
			move_and_slide()
		"roll":
			velocity = velocity.move_toward(Vector2.ZERO, friction*delta)
			move_and_slide()
		"still":
			pass
		"preserve":
			pass
		"serve":
			pass

func changeState(desiredState):
	match state:
		"bouncing":
			sprite.position.y = -1
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

func vectorToString(vec):
	vec = vec.normalized()
	var string = ""
	if vec.y >= 0.382683:
		string += "down"
	elif vec.y <= -0.382683:
		string += "up"
	if vec.x >= 0.382683:
		string += "right"
	elif vec.x <= -0.382683:
		string += "left"
	return string

func _on_hit_box_area_entered(area):
	if ballShadowHitBox.has_overlapping_areas() && netCollision == false:
		netCollision = true
		if velocity.y  > 0 && position.y >= 32 || velocity.y < 0 && position.y <=33:
			velocity = velocity*0.5
			zVelocity = zVelocity*0.5
		else:
			velocity = velocity*-0.7

func _on_shadow_hit_box_area_entered(area):
	if area.get_name().contains("Racket") && sprite.position.y > -20 && racketCollision == false:
		racketCollision = true
		netCollision = false
		velocity = velocity*-2
		zVelocity = -50
		zVelocityPrev = 0
	elif ballHitBox.has_overlapping_areas() && netCollision == false:
		netCollision = true
		if velocity.y  > 0 && position.y >= 31 || velocity.y < 0 && position.y <=33:
			velocity = velocity*0.5
			zVelocity = zVelocity*0.5
		else:
			velocity = velocity*-0.2
	elif area.get_name().contains("Boundary"):
		velocity = -velocity*0.9
		netCollision = false
