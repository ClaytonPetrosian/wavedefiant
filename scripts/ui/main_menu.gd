## main_menu.gd - Main menu screen
extends Control

func _ready() -> void:
	var start_btn = get_node_or_null("StartButton")
	if start_btn:
		start_btn.pressed.connect(_on_start)
	
	var quit_btn = get_node_or_null("QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)
	
	# Show high score
	var hs_label = get_node_or_null("HighScoreLabel")
	if hs_label:
		hs_label.text = "Best: %d" % GameManager.high_score

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/game_scene.tscn")

func _on_quit() -> void:
	get_tree().quit()
