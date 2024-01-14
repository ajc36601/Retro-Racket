extends CharacterBody2D
#
var state = "free"
var direction = "upLeft"
var directionVector = Vector2(-1,-1)
var acceleration = 6
var speed = 90

var input = Vector2.ZERO

var hitDirection = Vector2(1,-1)

var swingDelta = 0
var swingLength = 0.5

@onready var racketShadowHitBox = get_node("RacketShadowHitBox")
@onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	input = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input.y -= 1
	if Input.is_action_pressed("ui_down"):
		input.y += 1
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	
	match state:
		"free":
			if input.x != directionVector.x && input.x != 0:
				directionVector.x = input.x
			if input.y != directionVector.y && input.y != 0:
				directionVector.y = input.y
			elif input.y == 0:
				directionVector.y = hitDirection.y
			direction = getDirectionString(directionVector)
			velocity = velocity.move_toward(speed*input.normalized(),acceleration)
			if velocity == Vector2.ZERO:
				animationPlayer.play("idle_"+direction)
			else:
				animationPlayer.play("run_"+direction)
			
			if Input.is_action_pressed("swing"):
				changeState("swing")
		"locked":
			pass
		"swing":
			swingDelta += delta
			if swingDelta > swingLength:
				changeState("free")
			velocity = velocity.move_toward(Vector2.ZERO,acceleration*0.5)
		"dive":
			pass
		"preserve":
			pass
		"serve":
			pass
	move_and_slide()

func _ready():
	animationPlayer.set_speed_scale(0.8)

func changeState(desiredState):
	match state:
		"free":
			pass
		"locked":
			pass
		"swing":
			swingDelta = 0
			racketShadowHitBox.set_monitorable(false)
		"dive":
			pass
		"preserve":
			pass
		"serve":
			pass
	
	match desiredState:
		"free":
			pass
		"locked":
			pass
		"swing":
			animationPlayer.play("swing_"+getDirectionString(hitDirection))
			racketShadowHitBox.set_monitorable(true)
		"dive":
			pass
		"preserve":
			pass
		"serve":
			pass
	
	state = desiredState

func getDirectionString(vector):
	if vector == Vector2(-1,-1):
		return "upLeft"
	if vector == Vector2(1,-1):
		return "upRight"
	if vector == Vector2(-1,1):
		return "downLeft"
	if vector == Vector2(1,1):
		return "downRight"
