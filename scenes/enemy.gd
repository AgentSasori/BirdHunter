extends Area2D

@export var speed = 100
@export var points = 10
var alive = true
var speed_min = 400
var speed_max = 1000
var spawn_y_min = 100
var spawn_y_max = 900

func _ready():
	randomize()
	if randi() % 10 <= 5: # spwwn left -> fly to right
		global_position = Vector2(-1920*2, randi_range(spawn_y_min, spawn_y_max))
		speed += randi_range(speed_min, speed_max)
	else:
		global_position = Vector2(1920 * 2, randi_range(spawn_y_min, spawn_y_max))
		speed -= randi_range(speed_min, speed_max)
		$AnimatedSprite2D.flip_h = true
	# GEHT NICHT:
	
	var scaling = randf_range(0.9, 1.1)
	$AnimatedSprite2D.scale = Vector2(scaling, scaling)
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.speed_scale = speed * 0.006 # ajust the animation speed to the speed of movement
	
	points *= abs(speed) * 0.01
	
	#print("Birdie startet at", global_position, " with speed of ", speed, "and scale of", scale)
	
func _process(delta):
	if alive == true:
		position.x += speed * delta
	else:
		position.y += 20

	if position.x > 4000 or position.y > 1000: # background * 2 size
		print("Birdy out of view...bye", position)
		die()
	
func hit():
	alive = false
	$AnimatedSprite2D.play("dead")
	
func die():
	queue_free()
