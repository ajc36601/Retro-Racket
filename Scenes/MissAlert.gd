extends Node2D

var alert = false
var speed = 12
var opacitySpeed = 255
var opacity = 255

@onready var label = get_node("Label")

func _ready():
	pass

func _process(delta):
	if(alert):
		position.y -= speed*delta
		opacity -= opacitySpeed*delta
		modulate.a8 = opacity
		if(modulate.a8 <= 0):
			alert = 0
			visible = false
			modulate.a8 = 255
			opacity = 255

func start_alert(startPosition, text):
	position = startPosition
	visible = true
	alert = true
	modulate.a8 = 255
	opacity = 255
	label.text = text
