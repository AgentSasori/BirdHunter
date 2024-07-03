extends Node2D


@onready var crosshair_node = preload("res://scenes/crosshair.tscn")
@onready var background_node = preload("res://scenes/parallax_background.tscn")
#@onready var game_node = preload("res://scenes/game.tscn")

var crosshair = null
var background = null
const CREDITS = [
	"coding: AgentSasori",
	"title song: suno.ai",
	"title image: playground.ai",
	"birds-gfx: opengameart",
	"background: kenney.nl",
]
@onready var credits_label = $CanvasLayer/Creditstext
var credit_counter = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Titlesong.play()
	_fade_in()

func game_over(points, birds_killed, total_spawned, total_shots_fired):
	print("GAME OVER")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if points:
		$CanvasLayer/Gameover.show()
		$CanvasLayer/Gameover/Score.text = "Score: " + str(points)
		$CanvasLayer/Gameover/Birds.text = "Birds: " + str(total_spawned)
		$CanvasLayer/Gameover/Kills.text = "Kills: " + str(birds_killed)
		$CanvasLayer/Gameover/Shots.text = "Shots: " + str(total_shots_fired)
		
	else:
		$CanvasLayer/Gameover.hide()
		
	$CanvasLayer.show()
	$Titlesong.play()
	_fade_in()

func _fade_in():
	if credit_counter >= len(CREDITS)-1:
		credit_counter = 0
	else:
		credit_counter += 1
	credits_label.text = CREDITS[credit_counter]
	var tween = create_tween()
	tween.tween_property(credits_label,"modulate:a", 1, 1)
	tween.connect("finished",_fade_out)
	
func _fade_out():
	var tween = create_tween()
	tween.tween_property(credits_label,"modulate:a", 0, 3)
	tween.connect("finished",_fade_in)

#
# BUTTONS
#
func _on_start_pressed():
	crosshair = crosshair_node.instantiate()
	add_child(crosshair)
	#background = background_node.instantiate()
	#add_child(background)

	$CanvasLayer.hide()
	$CanvasLayer/Gameover.hide()
	crosshair.connect("game_over", game_over)
	$Titlesong.stop()

func _on_exit_pressed():
	get_tree().quit()
