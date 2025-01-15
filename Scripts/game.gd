extends Node2D

var state

var whosServe
var player1Score
var player2Score
var player1GameScore
var player2GameScore

@onready var player1 = get_node("court/ySort/player1")
@onready var player2 = get_node("court/ySort/player2")
@onready var score = get_node("Score/ScoreText")

func _ready():
	var stretch = Vector2(get_window().size.x/272.0, get_window().size.y/224.0)
	set_position(Vector2(round((stretch.x/stretch.y*272-272)/2+position.x),position.y))
	resetScore()
	changeState("play")

func _process(delta):
	match state:
		"play":
			pass
		"fault":
			pass
	if Input.is_action_just_pressed("player1Scored"):
		player1Scored()
	if Input.is_action_just_pressed("player2Scored"):
		player2Scored()
	

func changeState(desiredState):
	match state:
		"play":
			pass
		"fault":
			pass
	
	match desiredState:
		"play":
			player1Serve()
		"fault":
			pass

func fault():
	player1.changeState("locked")
	player2.changeState("locked")

func resetScore():
	player1Score = 0
	player2Score = 0
	score.text = "0 - 0"

func player1Scored():
	var scoreStr
	player1Score += 1
	if (player1Score >= 4):
		if (player1Score - player2Score >= 2):
			scoreStr = "Game"
		elif (player2Score >= 3):
			if (player1Score == player2Score):
				scoreStr = "40 - 40"
			else:
				scoreStr = "Ad - 40"
	else:
		if (player1Score == 3):
			scoreStr = "40 - "
		elif (player1Score == 2):
			scoreStr = "30 - "
		else:
			scoreStr = "15 - "
		
		if (player2Score == 3):
			scoreStr += "40"
		elif (player2Score == 2):
			scoreStr += "30"
		elif (player2Score == 1):
			scoreStr += "15"
		else:
			scoreStr += "0"
	print("Score: "+str(player1Score)+" - "+str(player2Score))
	score.text = scoreStr

func player2Scored():
	var scoreStr
	player2Score += 1
	if (player2Score >= 4):
		if (player2Score - player1Score >= 2):
			scoreStr = "Game"
		elif (player1Score >= 3):
			if (player2Score == player1Score):
				scoreStr = "40 - 40"
			else:
				scoreStr = "40 - Ad"
	else:
		if (player1Score == 3):
			scoreStr = "40 - "
		elif (player1Score == 2):
			scoreStr = "30 - "
		elif (player1Score == 1):
			scoreStr = "15 - "
		else:
			scoreStr = "0 - "
		
		if (player2Score == 3):
			scoreStr += "40"
		elif (player2Score == 2):
			scoreStr += "30"
		else:
			scoreStr += "15"
	print("Score: "+str(player1Score)+" - "+str(player2Score))
	score.text = scoreStr

func player1Serve():
	player1.changeState("preserve")
	player1.hasPossesion = true
	player2.hasPossesion = false

func player2Serve():
	player2.changeState("preserve")
	player2.hasPossesion = true
	player1.hasPossesion = false
