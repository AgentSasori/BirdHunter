extends Control

var enemies = []
var aimed = []
var total_spawned = 0
var total_shots_fired = 0
var points = 0
var birds_killed = 0
var ammo = 30
var mag_size = 4
var mag = 4

var birds = [
	preload("res://scenes/bird_fat.tscn"),
	preload("res://scenes/bird_green.tscn"),
	preload("res://scenes/bird_grey.tscn"),	
	preload("res://scenes/bird_koks.tscn"),
	preload("res://scenes/bird_monster.tscn"),
	preload("res://scenes/bird_pot.tscn"),
	preload("res://scenes/bird_red.tscn"),
]

@onready var bonus_node = preload("res://scenes/bonusbox.tscn")
@onready var shutgun_shell_node = preload("res://scenes/shotgun_shell.tscn")
@onready var main_node
signal game_over	

# Called when the node enters the scene tree for the first time.
func _ready():
	main_node = get_parent()
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	$Spawntimer.autostart = true
	$Spawntimer.start()
	$Music.play()
	_update_ui()

func _cleanup():
	# clean up the birds on screen
	print("Cleaning up ", len(enemies), "birds")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	queue_free()

func _update_ui():
	$UI/ColorRect/Points.text = "Points: " + str(points)
	$UI/ColorRect/Ammo.text = "Ammo: " + str(ammo)
	$UI/ColorRect/Kills.text = "Kills: " + str(birds_killed)
	$UI/ColorRect/Mag.text = "Mag: " + str(mag)
	$UI/ColorRect/Birds.text = "Birds: " + str(total_spawned)
	
	# GAME OVER
	if ammo == 0 and mag == 0:#ammo in range(1, 10) and mag in range(1, mag_size):
		_cleanup()
		# Send signal to game-node
		emit_signal("game_over", points, birds_killed, total_spawned, total_shots_fired)
		#destoy itself
		#queue_free()

func spawn_box():
	var box = bonus_node.instantiate()
	
	get_parent().add_child(box)
	box.global_position.y = 0
	box.global_position.x = randi_range(50, 1900)
	
func _spawn_shell():
	var shell = shutgun_shell_node.instantiate()
	add_child(shell)
	shell.global_position = global_position + Vector2(0,500) # crosshair pos + 500 (bottom
	shell.apply_central_impulse(Vector2(600, -1000))
	#shell.apply_torque_impulse(5000)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(shell, "rotation_degrees",  randi_range(0, 360), randi_range(2, 3)) #randf_range(0.1,2.9))# [-1,1].pick_random())
	tween.tween_callback(shell.queue_free).set_delay(2)
	
func _process(delta):
	global_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("ui_esc"):
		$UI/ColorRect2.visible = true
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("ui_accept"):
		if mag > 0:
			$Shot.play()
			_spawn_shell()
			total_shots_fired += 1
			mag -= 1
			for target in aimed:
				if target.is_in_group("enemy"):
					print("You shot ", target)
					points += int(target.points)
					birds_killed += 1
					target.hit()
					enemies.erase(target)
					aimed.erase(target)
					$Dead.play()
					
					if birds_killed % 10 == 0:
						spawn_box()
				elif target.is_in_group("ammo"):
					print("HIT A BONUS BOX!")
					target.queue_free()
					ammo += mag_size * 3
			_update_ui()
		else:
			if $ReloadTimer.is_stopped():
				$Reloading.visible = true
				$UI/ColorRect/Mag.text = "Reload"
				$Reload.play()
				$ReloadTimer.start()
			
func _on_area_2d_area_entered(area):
	print("Adding bird", area)
	aimed.append(area)

func _on_area_2d_area_exited(area):
	print("removing bird", area)
	aimed.erase(area)

func _on_reload_timer_timeout():
	$Reloading.visible = false	
	if ammo > mag_size:
		mag += mag_size
		ammo -= mag_size
	else:
		mag += ammo
		ammo = 0
	_update_ui()

func _on_spawntimer_timeout():
	var newbird = birds.pick_random().instantiate()
	main_node.add_child(newbird)
	enemies.append(newbird)
	total_spawned += 1
	_update_ui()
	$Spawntimer.wait_time = randf_range(0.5, 2)

func _on_continue_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	$UI/ColorRect2.visible = false
	get_tree().paused = false
#
#func _on_main_menu_pressed():	
	#_cleanup()
	#emit_signal("game_over", points)
	##queue_free()
