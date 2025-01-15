extends CharacterBody2D

var state = "bouncing"
var isInPlay = false
var isBeingServed = false

var zEnergyConserved = 0.7
var xyEnergyConserved = 0.9
var zVelocity = -110
var zVelocityPrev = zVelocity/zEnergyConserved
var gravity = 125
var friction = 20
var size = 4

var netCollision = false
var racketCollision1 = false
var racketCollision2 = false
var playerCollision1 = false
var playerCollision2 = false

var predictedPosition = Vector2.ZERO
var timeToBounce = 0

@onready var sprite = get_node("sprite")
@onready var ballHitBox = get_node("sprite/BallHitBox")
@onready var ballShadowHitBox = get_node("BallShadowHitBox")
@onready var player = get_node("AnimationPlayer")

@onready var player1 = get_node("../player1")
@onready var racket1ShadowHitBox = get_node("../player1/RacketShadowHitBox")

@onready var player2 = get_node("../player2")
@onready var racket2ShadowHitBox = get_node("../player2/RacketShadowHitBox")

@onready var missAlert = get_node("../MissAlert")
@onready var ballMarker = get_node("../../ballMarker")

@onready var game = $"../../.."

func _ready():
	velocity = Vector2(0,-47)
var timer = 0
func _physics_process(delta):
	match state:
		"bouncing":
			if timeToBounce > 0:
				timeToBounce -= delta
			if sprite.position.y >= -1 && zVelocity > 0:
				sprite.position.y = -1
				if abs(zVelocity) >= abs(zVelocityPrev) && zVelocityPrev != 0:
					zVelocity = 0
					if velocity != Vector2.ZERO:
						changeState("roll")
					else:
						changeState("still")
				else:
					velocity = velocity*xyEnergyConserved
					zVelocityPrev = zVelocity
					zVelocity = -zEnergyConserved*zVelocity
					if isInPlay:
						if isBeingServed:
							if player2.hasPossesion:
								isInOrOut(true, player1.hitDirection)
							else:
								isInOrOut(true, player2.hitDirection)
							isBeingServed = false
						else:
							if player2.hasPossesion:
								isInOrOut(false, player1.hitDirection)
							else:
								isInOrOut(false, player2.hitDirection)
							isInPlay = false
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
			
			if velocity != Vector2.ZERO:
				player.set_speed_scale(velocity.length()/25)
				player.play(str(size)+vectorToString(velocity))
			else:
				player.play(str(size))
			move_and_slide()
		"roll":
			player.set_speed_scale(velocity.length()/25)
			velocity = velocity.move_toward(Vector2.ZERO, friction*delta)
			move_and_slide()
		"still":
			pass
		"preserve":
			position = player1.position + Vector2(8, 0)
		"serve":
			if sprite.position.y > -17:
				changeState("preserve")
				player1.changeState("preserve")
			
			sprite.move_local_y(zVelocity*delta)
			zVelocity = zVelocity+gravity*delta
			
			if sprite.position.y <= -70:
				size = 8
			elif sprite.position.y <= -35:
				size = 6
			else:
				size = 4
			player.play(str(size))
			move_and_slide()

func changeState(desiredState):
	match state:
		"bouncing":
			sprite.position.y = -1
		"rolling":
			pass
		"still":
			pass
		"preserve":
			zVelocity = -105
			zVelocityPrev = 0
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
			velocity = Vector2.ZERO
			player.stop()
			sprite.position.y = -17
		"serve":
			if position.x - floor(position.x) >= 0.49 && position.x - floor(position.x) <= 0.51:
				position.x = position.x + 0.1
	
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

func _on_ball_hit_box_area_entered(area):
	if area.get_name().contains("Net") && ballShadowHitBox.has_overlapping_areas() && netCollision == false:
		for i in ballShadowHitBox.get_overlapping_areas().size():
			if ballShadowHitBox.get_overlapping_areas()[i].get_name().contains("Net"):
				netCollision = true
				if velocity.y  > 0 && sprite.position.y <= -18 || velocity.y < 0 && sprite.position.y <= -18:
					velocity = velocity*0.2
					zVelocity = zVelocity*0.5
					if velocity.y > 0:
						position.y += 2
					else:
						position.y -= 2
					print("Ball clipped net collision triggered by hitbox")
					print("y position at clip: ")
					print(sprite.position.y)
				else:
					velocity = 0.2*Vector2(velocity.x, -velocity.y)
					print("Ball direct net collision triggered by hitbox")
					print("y position at collision: ")
					print(sprite.position.y)
				return
	elif area.get_parent().get_name().contains("player1"):
		if ballShadowHitBox.has_overlapping_bodies() && playerCollision1 == false:
			for i in ballShadowHitBox.get_overlapping_bodies().size():
				if ballShadowHitBox.get_overlapping_bodies()[i].get_name().contains("player1"):
					playerCollision1 = true
					velocity = -0.3*velocity
					print("Ball collision with player 1 triggered by hitbox")
					return
	elif area.get_parent().get_name().contains("player2"):
		if ballShadowHitBox.has_overlapping_bodies() && playerCollision2 == false:
			for i in ballShadowHitBox.get_overlapping_bodies().size():
				if ballShadowHitBox.get_overlapping_bodies()[i].get_name().contains("player2"):
					playerCollision2 = true
					velocity = -0.3*velocity
					print("Ball collision with player 2 triggered by hitbox")
					return

func _on_shadow_hit_box_area_entered(area):
	if area.get_parent().get_name().contains("player1") && racketCollision1 == false && (player1.state == "swing" && sprite.position.y > -20 || player1.state == "smash" && sprite.position.y > -32 && sprite.position.y < -19):
		racketCollision1 = true
		netCollision = false
		var xyVelocity = Vector2(1,0).rotated(racket1ShadowHitBox.rotation)
		if(player1.state == "preswing"):
			xyVelocity *= velocity.length()/5
			zVelocity = -50
			print("Preswing collision")
		elif(player1.state == "smash"):
			print("smash at y position: ")
			print(sprite.position.y)
			xyVelocity *= 50
			zVelocity = 5
		else:
			var totalVelocity = player1.swingPower
			if (player1.swingType == "none"):
				print("normal swing")
				xyVelocity *= totalVelocity*cos(deg_to_rad(45))
				zVelocity = -totalVelocity*sin(deg_to_rad(45))
			else:
				totalVelocity *= 0.0675*player1.meter.frame+0.75
				if (player1.swingType == "low"):
					print("Low swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(30))
					zVelocity = -totalVelocity*sin(deg_to_rad(30))
				elif (player1.swingType == "medium"):
					print("Medium swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(45))
					zVelocity = -totalVelocity*sin(deg_to_rad(45))
				elif (player1.swingType == "high"):
					print("High swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(60))
					zVelocity = -totalVelocity*sin(deg_to_rad(60))
			print("Ball Speed:")
			print(totalVelocity)
			print("Swing collision")
		if player1.hitDirection.y == -1:
			if player1.hitDirection.x == -1:
				velocity = xyVelocity.rotated(deg_to_rad(90))
			else: 
				velocity = xyVelocity.rotated(deg_to_rad(-90))
		else: 
			if player1.hitDirection.x == -1:
				velocity = xyVelocity.rotated(deg_to_rad(-90))
			else:
				velocity = xyVelocity.rotated(deg_to_rad(90))
		zVelocityPrev = 0
		player1.hasPossesion = false
		player2.hasPossesion = true
	elif (area.get_parent().get_name().contains("player1") && racketCollision1 == false):
		if(player1.state == "swing" && sprite.position.y <= -20 || player1.state == "smash" && sprite.position.y <= -32):
			print("miss too high")
			missAlert.start_alert(position, "high")
		elif (player1.state == "smash" && sprite.position.y >= -19):
			print("miss too low")
			missAlert.start_alert(position, "low")
	elif area.get_parent().get_name().contains("player2") && racketCollision2 == false && (player2.state == "swing" && sprite.position.y > -20 || player2.state == "smash" && sprite.position.y > -32 && sprite.position.y < -19):
		racketCollision2 = true
		netCollision = false
		var xyVelocity = Vector2(1,0).rotated(racket2ShadowHitBox.rotation)
		if(player1.state == "preswing"):
			xyVelocity *= velocity.length()/5
			zVelocity = -50
			print("Preswing collision")
		elif(player1.state == "smash"):
			print("smash at y position: ")
			print(sprite.position.y)
			xyVelocity *= 50
			zVelocity = 5
		else:
			var totalVelocity = player2.swingPower
			if (player2.swingType == "none"):
				print("normal swing")
				xyVelocity *= totalVelocity*cos(deg_to_rad(45))
				zVelocity = -totalVelocity*sin(deg_to_rad(45))
			else:
				totalVelocity *= 0.0675*player1.meter.frame+0.75
				if (player2.swingType == "low"):
					print("Low swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(30))
					zVelocity = -totalVelocity*sin(deg_to_rad(30))
				elif (player2.swingType == "medium"):
					print("Medium swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(45))
					zVelocity = -totalVelocity*sin(deg_to_rad(45))
				elif (player2.swingType == "high"):
					print("High swing")
					xyVelocity *= totalVelocity*cos(deg_to_rad(60))
					zVelocity = -totalVelocity*sin(deg_to_rad(60))
			print("Ball Speed:")
			print(totalVelocity)
			print("Swing collision")
		if player2.hitDirection.y == -1:
			if player2.hitDirection.x == -1:
				velocity = xyVelocity.rotated(deg_to_rad(90))
			else: 
				velocity = xyVelocity.rotated(deg_to_rad(-90))
		else: 
			if player2.hitDirection.x == -1:
				velocity = xyVelocity.rotated(deg_to_rad(-90))
			else:
				velocity = xyVelocity.rotated(deg_to_rad(90))
		zVelocityPrev = 0
		player1.hasPossesion = true
		player2.hasPossesion = false
	elif (area.get_parent().get_name().contains("player2") && racketCollision2 == false):
		if(player2.state == "swing" && sprite.position.y <= -20 || player2.state == "smash" && sprite.position.y <= -32):
			print("miss too high")
			missAlert.start_alert(position, "high")
		elif (player2.state == "smash" && sprite.position.y >= -19):
			print("miss too low")
			missAlert.start_alert(position, "low")
	elif area.get_name().contains("Boundary"):
		netCollision = false
		if(area.get_name().contains("bottom") || area.get_name().contains("top")):
			velocity = 0.4*Vector2(velocity.x, -velocity.y)
		elif(area.get_name().contains("left") || area.get_name().contains("right")):
			velocity = 0.4*Vector2(-velocity.x, velocity.y)
		print("Ball collision with boundary")
		print("Boundary name: ")
		print(area.get_name())
	elif ballHitBox.has_overlapping_areas() && netCollision == false && area.get_name().contains("Net"):
		for i in ballHitBox.get_overlapping_areas().size():
			if ballHitBox.get_overlapping_areas()[i].get_name().contains("Net") && sprite.position.y >= -20:
				netCollision = true
				if sprite.position.y <= -18:
					velocity = velocity*0.2
					zVelocity = zVelocity*0.5
					if velocity.y > 0:
						position.y += 2
					else:
						position.y -= 2
					print("Ball clipped net collision triggered by shadow")
					print("y position at clip: ")
					print(sprite.position.y)
				else:
					velocity = 0.2*Vector2(velocity.x, -velocity.y)
					print("Ball direct net collision triggered by shadow")
					print("y position at collision: ")
					print(sprite.position.y)

func _on_ball_shadow_hit_box_body_entered(body):
	if ballHitBox.has_overlapping_areas() && playerCollision1 == false:
		for i in ballHitBox.get_overlapping_areas().size():
			if ballHitBox.get_overlapping_areas()[i].get_parent().get_name().contains("player1"):
				playerCollision1 = true
				velocity = -0.3*velocity
				print("Ball collision with player 1 triggered by shadow")
				return
	if ballHitBox.has_overlapping_areas() && playerCollision2 == false:
		for i in ballHitBox.get_overlapping_areas().size():
			if ballHitBox.get_overlapping_areas()[i].get_parent().get_name().contains("player2"):
				playerCollision2 = true
				velocity = -0.3*velocity
				print("Ball collision with player 2 triggered by shadow")
				return

func isInOrOut(serveBool, directionVector):
	var list = ballShadowHitBox.get_overlapping_areas()
	print(list)
	for n in list.size():
		if serveBool && list[n].get_name().contains("Service"):
			if(directionVector.x == -1 && list[n].get_name().contains("Left")):
				if(directionVector.y == -1 && list[n].get_name().contains("top")):
					return
				elif(directionVector.y == 1 && list[n].get_name().contains("bottom")):
					return
			elif(directionVector.x == 1 && list[n].get_name().contains("Right")):
				if(directionVector.y == -1 && list[n].get_name().contains("top")):
					return
				elif(directionVector.y == 1 && list[n].get_name().contains("bottom")):
					return
		else:
			if(directionVector.y == -1 && list[n].get_name().contains("top")):
				return
			elif(directionVector.y == 1 && list[n].get_name().contains("bottom")):
				return
	game.fault()

func findPredictedPosition():
	print("TESTTTTTTTTTTTTT")
	timeToBounce = (-zVelocity+sqrt(pow(zVelocity, 2)-2*gravity*sprite.position.y))/gravity
	predictedPosition = position + velocity*timeToBounce
	ballMarker.position = predictedPosition

func changePossesion():
	if player1.hasPossesion:
		player1.hasPossesion = false
		player2.hasPossesion = true
	else:
		player1.hasPossesion = true
		player2.hasPossesion = false
