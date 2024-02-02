extends Node2D

@onready var game = get_node(".")
var stretch

@onready var dpad = get_node("dpad")

@onready var player1 = get_node("court/ySort/player1")

func _input(event):
	if event is InputEventScreenTouch && event.get_position().x > 425:
		player1.changeState("swing")

func _ready():
	player1.input = Vector2.ZERO
	stretch = Vector2(get_window().size.x/544.0, get_window().size.y/309.0)
	game.set_position(Vector2(round((stretch.x/stretch.y*544-544)/2+position.x),position.y))


func _on_leftbutton_pressed():
	player1.input.x = -1
	player1.input = player1.input.normalized()


func _on_leftbutton_released():
	if player1.input.x < 0:
		player1.input.x = 0


func _on_rightbutton_pressed():
	player1.input.x = 1
	player1.input = player1.input.normalized()


func _on_rightbutton_released():
	if player1.input.x > 0:
		player1.input.x = 0


func _on_upbutton_pressed():
	player1.input.y = -1
	player1.input = player1.input.normalized()


func _on_upbutton_released():
	if player1.input.y < 0:
		player1.input.y = 0


func _on_downbutton_pressed():
	player1.input.y = 1
	player1.input = player1.input.normalized()


func _on_downbutton_released():
	if player1.input.y > 0:
		player1.input.y = 0
