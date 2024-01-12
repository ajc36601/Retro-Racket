extends CharacterBody2D



func _physics_process(delta):
	move_and_slide()
	velocity = Vector2(0,-2)
