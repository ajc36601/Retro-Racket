extends Node2D

@onready var game = get_node(".")
var stretch

var thumbstickActive = false
@onready var thumbstickBase = get_node("thumbstickBase")
@onready var thumbstick = get_node("thumbstickBase/thumbstick")

@onready var player1 = get_node("court/ySort/player1")

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed() && event.get_position().x < 125:
			thumbstickBase.global_position = event.get_position()
			thumbstickBase.visible = true
			thumbstickActive = true
			print("TOUCH")
		elif !event.is_pressed() && thumbstickActive:
			thumbstick.global_position = thumbstickBase.global_position
			thumbstickBase.visible = false
			player1.input = Vector2.ZERO
			thumbstickActive = false
			print("RELEASE")
	if event is InputEventScreenTouch && event.get_position().x > 425:
		player1.changeState("swing")
	
	if event is InputEventScreenDrag && thumbstickActive:
		var vec = event.get_position() - thumbstickBase.global_position
		vec = vec.limit_length(60)
		if (event.get_position() - thumbstickBase.global_position).length() <= 60:
			thumbstick.global_position = event.get_position()
		else:
			thumbstick.global_position = vec + thumbstickBase.global_position
		player1.input = vec.normalized()*vec.length()/80

func _ready():
	player1.input = Vector2.ZERO
	stretch = Vector2(get_window().size.x/544.0, get_window().size.y/309.0)
	game.set_position(Vector2(round((stretch.x/stretch.y*544-544)/2+position.x),position.y))

func _physics_process(delta):
	pass
