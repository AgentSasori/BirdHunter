extends RigidBody2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position.y > 1080:
		print("Bonus box disapeard")
		queue_free()
