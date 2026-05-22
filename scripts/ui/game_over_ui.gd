## game_over_ui.gd - Game over screen
extends Control

func _ready() -> void:
	var btn = get_node_or_null("RestartButton")
	if btn:
		btn.pressed.connect(_on_restart)

func _on_restart() -> void:
	visible = false
	# Reload the game scene
	get_tree().reload_current_scene()
