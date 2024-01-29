extends Node2D

@onready var thumbstickBase = get_node("thumbstickBase")
@onready var thumbstick = get_node("thumbstickBase/thumbstick")

@onready var player1 = get_node("court/ySort/player1")

func _unhandled_input(event):
	if event is InputEventScreenTouch && event.get_position().x < 96:
		if event.is_pressed():
			thumbstickBase.global_position = event.get_position()
			thumbstickBase.visible = true
			print("TOUCH")
		else:
			thumbstick.global_position = thumbstickBase.global_position
			thumbstickBase.visible = false
			player1.input = Vector2.ZERO
			print("RELEASE")
	if event is InputEventScreenTouch && event.get_position().x > 368:
		player1.changeState("swing")
	
	if event is InputEventScreenDrag:
		var vec = event.get_position() - thumbstickBase.global_position
		vec = vec.limit_length(70)
		if (event.get_position() - thumbstickBase.global_position).length() <= 70:
			thumbstick.global_position = event.get_position()
		else:
			thumbstick.global_position = vec + thumbstickBase.global_position
		player1.input = vec.normalized()*vec.length()/80

func _ready():
	player1.input = Vector2.ZERO
