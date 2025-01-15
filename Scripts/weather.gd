extends Node2D

@onready var ySort = get_parent()

var puddleImg = ResourceLoader.load("res://Assets/Weather/puddle.png")
var rainDropImg = ResourceLoader.load("res://Assets/Weather/rain_drop.png")
var rainDropScript = ResourceLoader.load("res://Scripts/rainDrop.gd")
var rng = RandomNumberGenerator.new()

var rain = true
var rainDensity = 20
var spawnLength = 0.1
#every spawnLength seconds rainDensity drops spawn
var spawnDelta = 0

var puddle = true
var puddleDensity = 10
#max amount of puddles at once
var puddleChance = 0.05
#chance of rain drop becoming puddle
var puddleLength = 15
var puddleCount = 0
var puddleLocations = []


func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (rain && spawnDelta >= spawnLength):
		for i in rainDensity:
			var rainDropPosition = Node2D.new()
			var rainDrop = Sprite2D.new()
			rainDropPosition.add_child(rainDrop)
			ySort.add_child(rainDropPosition)
			rainDrop.texture = rainDropImg
			rainDrop.set_hframes(14)
			rainDrop.set_script(rainDropScript)
			rainDropPosition.position = Vector2(rng.randi_range(-132, 129)+0.5, rng.randi_range(-34, 61))
			rainDrop.global_position.y = global_position.y
			rainDrop.speed = rng.randi_range(100, 150)
			rainDrop.frame_time = 0.05
			rainDrop.set_process(true)
			if (puddle == true && puddleCount < puddleDensity):
				if (rng.randi_range(1, 1/puddleChance) == 1):
					var puddle = Sprite2D.new()
					puddle.self_modulate.a = 0
					puddle.texture = puddleImg
					ySort.add_sibling(puddle)
					puddle.position = Vector2(rng.randi_range(-115, 115), rng.randi_range(-45, 115))
					var validLocation = false
					while (!validLocation && puddleLocations.size()>0):
						validLocation = true
						for j in puddleLocations.size():
							if puddleLocations[j].distance_to(puddle.position) < 30:
								validLocation = false
						if !validLocation:
							puddle.position = Vector2(rng.randi_range(-115, 115), rng.randi_range(-45, 115))
					puddleLocations.append(puddle.position)
					var temp = rng.randi_range(1, 4)
					puddle.scale = Vector2(temp, temp)
					get_tree().create_tween().tween_property(puddle, "self_modulate:a", 1, 3)
					puddleCount += 1
		spawnDelta = 0
	else:
		spawnDelta += delta

