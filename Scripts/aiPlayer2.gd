extends CharacterBody2D

var aiOn = true
var aiState = "setUpPosition"
var positionAwayFromBall = Vector2(10, 5)
var swingTimer
var targetPosition 

var state = "free"
var direction = "upLeft"
var directionVector = Vector2(-1,1)
var hasPossesion = true

var acceleration = 200
var deceleration = 300
var speed = 80
var swingPower = 100
var dominantHand = "right"

var swingType = "none"
var input = Vector2.ZERO
var hitDirection = Vector2(1,1)

var swingDelta = 0
var swingLength = 0.4

var smashDelta = 0
var smashLength = 0.3

var serveDelta = 0
var serveLength = 0.3

@onready var ball = get_parent().get_node("ball")
@onready var racketShadowHitBox = get_node("RacketShadowHitBox")
@onready var animationPlayer = $AnimationPlayer
@onready var meter = get_node("meter")
@onready var meterAnimationPlayer = meter.get_node("AnimationPlayer")
@onready var missAlert = get_node("../MissAlert")

func _ready():
	animationPlayer.set_speed_scale(0.8)
	changeAiState("setUpPosition")

func _physics_process(delta):
	print(aiState)
	match aiState:
		"seekBall":
			print(ball.predictedPosition)
			print(position)
			#Amount of time player will move if stopped inputting now
			var t = velocity.length()/deceleration
			#Distance player will move if stopped inputting now
			var d = -0.5*deceleration*t*t+velocity.length()*t
			
			#use targetPosition instead when can
			if d < (targetPosition - position).length():
				input = targetPosition - position
			else:
				print("d:"+str(d))
				print((targetPosition - position).length())
				changeAiState("waitToHit")
			input = input.normalized()
		"waitToHit":
			if swingTimer > 0:
				swingTimer -= delta
			else:
				changeState("swing")
				changeAiState("setUpPosition")
		"setUpPosition":
			if hasPossesion && state != "swing":
				changeAiState("seekBall")
		"waitForReturn":
			pass
	
	match state:
		"free":
			if ball.position.x < position.x:
				hitDirection.x = -1
			else:
				hitDirection.x = 1
			
			if input.x != 0:
				if input.x > 0:
					directionVector.x = 1
				else:
					directionVector.x = -1
			elif input.x == 0:
				directionVector.x = hitDirection.x
			if input.y != 0:
				if input.y > 0:
					directionVector.y = 1
				else:
					directionVector.y = -1
			elif input.y == 0:
				directionVector.y = hitDirection.y
			direction = getDirectionString(directionVector, false)
			
			if input != Vector2.ZERO:
				velocity = velocity.move_toward(speed*input,acceleration*delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta)
			
			if velocity == Vector2.ZERO:
				animationPlayer.play("idle_"+direction)
			else:
				animationPlayer.play("run_"+direction)
				
			if Input.is_action_just_pressed("swing2"):
				changeState("swing")
			elif Input.is_action_pressed("low_swing2"):
				changeState("preswing")
				swingType = "low"
			elif Input.is_action_pressed("medium_swing2"):
				changeState("preswing")
				swingType = "medium"
			elif Input.is_action_pressed("high_swing2"):
				changeState("preswing")
				swingType = "high"
			elif Input.is_action_pressed("smash2"):
				changeState("smash")
			elif Input.is_action_pressed("serve2"):
				changeState("preserve")
			move_and_slide()
		"locked":
			pass
		"preswing":
			velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta*0.75)
			if !Input.is_action_pressed(swingType+"_swing"):
				changeState("swing")
			move_and_slide()
		"swing":
			swingDelta += delta
			if swingDelta > swingLength:
				changeState("free")
			velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta*0.75)
		"smash":
			smashDelta += delta
			if smashDelta > smashLength:
				changeState("free")
			velocity = velocity.move_toward(Vector2.ZERO,deceleration*delta*0.75)
		"preserve":
			velocity = velocity.move_toward(speed*Vector2(input.x, 0),deceleration*delta*0.75)
			if(position.x < -83):
				position.x = -83
				velocity = Vector2.ZERO
			elif(position.x > -2):
				position.x = -2
				velocity = Vector2.ZERO
			
			if Input.is_action_pressed("swing"):
				changeState("serve")
			move_and_slide()
		"serve":
			if Input.is_action_just_pressed("swing") && animationPlayer.get_current_animation().contains("Throw"):
				animationPlayer.play("serve_upRight")
				if ball.sprite.position.y >= -41 && ball.sprite.position.y <= -25:
					ball.changeState("bouncing")
					ball.velocity = Vector2(60,-80)
					ball.zVelocity = -50
					changeState("free")
			
	if velocity.x == 0 && position.x - floor(position.x) >= 0.48 && position.x - floor(position.x) <= 0.52:
		position.x += 0.1
	if velocity.y == 0 && position.y - floor(position.y) >= 0.48 && position.y - floor(position.y) <= 0.52:
		position.y += 0.1

func changeState(desiredState):
	match state:
		"free":
			pass
		"locked":
			pass
		"preswing":
			pass
		"swing":
			meterAnimationPlayer.stop()
			swingDelta = 0
			racketShadowHitBox.set_monitorable(false)
			ball.racketCollision2 = false
			meter.visible = false
			swingType = "none"
			if(hasPossesion && !missAlert.alert):
				missAlert.start_alert(ball.position, "miss")
				changeAiState("locked")
		"smash":
			smashDelta = 0
			racketShadowHitBox.position.y = 1
			racketShadowHitBox.set_monitorable(false)
			ball.racketCollision2 = false
			if(hasPossesion && !missAlert.alert):
				missAlert.start_alert(ball.position, "miss")
				changeAiState("locked")
		"preserve":
			velocity = Vector2.ZERO
		"serve":
			serveDelta = 0
	
	match desiredState:
		"free":
			pass
		"locked":
			pass
		"preswing":
			meter.visible = true
			meterAnimationPlayer.play("meter")
			animationPlayer.play("preswing_"+getDirectionString(hitDirection, false))
			racketShadowHitBox.set_monitorable(true)
		"swing":
			meterAnimationPlayer.pause()
			animationPlayer.play("swing_"+getDirectionString(hitDirection, false))
			racketShadowHitBox.set_monitorable(true)
		"smash":
			animationPlayer.play("smash_"+getDirectionString(hitDirection, true)+"_"+dominantHand)
			racketShadowHitBox.set_monitorable(true)
		"preserve":
			velocity = Vector2.ZERO
			animationPlayer.play("preserve_upRight")
			ball.changeState("preserve")
			if state != "serve":
				position = Vector2(-83, 114)
		"serve":
			animationPlayer.play("serveThrow_upRight")
			ball.changeState("serve")
	
	state = desiredState

func getDirectionString(vector, justUpOrDown):
	if vector == Vector2(-1,-1):
		if justUpOrDown:
			return "up"
		return "upLeft"
	if vector == Vector2(1,-1):
		if justUpOrDown:
			return "up"
		return "upRight"
	if vector == Vector2(-1,1):
		if justUpOrDown:
			return "down"
		return "downLeft"
	if vector == Vector2(1,1):
		if justUpOrDown:
			return "down"
		return "downRight"

func changeAiState(desiredState):
	match aiState:
		"seekBall":
			input = Vector2.ZERO
		"waitToHit":
			swingTimer = 0
		"setUpPosition":
			pass
		"waitForReturn":
			pass
	
	match desiredState:
		"seekBall":
			ball.findPredictedPosition()
			var d = ball.predictedPosition - position
			var right = Vector2(abs(positionAwayFromBall.x), -hitDirection.y*abs(positionAwayFromBall.y))
			var left = Vector2(-abs(positionAwayFromBall.x), -hitDirection.y*abs(positionAwayFromBall.y))
			if((d + left).length() < (d + right).length()):
				positionAwayFromBall = left
			else:
				positionAwayFromBall = right
			targetPosition = ball.predictedPosition + positionAwayFromBall
		"waitToHit":
			#ball sprite height when hit
			var c = 0
			# ball velocity after it bounces
			var b = -(ball.timeToBounce*ball.gravity+ball.zVelocity)*ball.zEnergyConserved
			# half of ball gravity
			var a = 0.5*ball.gravity
			var timeToHit = ball.timeToBounce + (-b - sqrt(b*b - 4*a*c)) / (2*a)
			swingTimer = timeToHit
			print("Nan: "+str(sqrt(b*b - 4*a*c)))
			print("a: "+str(a))
			print("b: "+str(b))
			print("c: "+str(c))
			var timeToSwing
		"setUpPosition":
			pass
		"waitForReturn":
			pass
	
	aiState = desiredState

