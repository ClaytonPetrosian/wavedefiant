## main_menu.gd - Animated main menu
extends Control

var title_tween: Tween = null

func _ready() -> void:
	var start_btn = get_node_or_null("StartButton")
	if start_btn:
		start_btn.pressed.connect(_on_start)

	var quit_btn = get_node_or_null("QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

	var hs_label = get_node_or_null("HighScoreLabel")
	if hs_label:
		hs_label.text = "🏆 最高分: %d" % GameManager.high_score

	# Animate title
	var title = get_node_or_null("TitleLabel")
	if title:
		title.position.y = -100
		var tween = create_tween()
		tween.tween_property(title, "position:y", 0, 0.5).set_ease(Tween.EASE_OUT_BOUNCE)

	# Animate buttons
	var buttons = [get_node_or_null("StartButton"), get_node_or_null("QuitButton")]
	for i in range(buttons.size()):
		var btn = buttons[i]
		if btn:
			btn.modulate.a = 0
			var tween = create_tween()
			tween.tween_property(btn, "modulate:a", 1.0, 0.3).set_delay(0.3 + i * 0.15)

func _on_start() -> void:
	# Button press animation
	var btn = get_node_or_null("StartButton")
	if btn:
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
		await get_tree().create_timer(0.15).timeout

	get_tree().change_scene_to_file("res://scenes/levels/game_scene.tscn")

func _on_quit() -> void:
	get_tree().quit()
