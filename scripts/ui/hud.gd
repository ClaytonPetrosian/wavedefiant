## hud.gd - In-game HUD (HP, XP, Wave, Score)
extends Control

func _ready() -> void:
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.state_changed.connect(_on_state_changed)

func _process(delta: float) -> void:
	var xp_bar = get_node_or_null("XPBar")
	var level_label = get_node_or_null("LevelLabel")
	
	if xp_bar:
		xp_bar.max_value = GameManager.xp_to_next_level
		xp_bar.value = GameManager.current_xp
	
	if level_label:
		level_label.text = "Lv.%d" % GameManager.current_level

func _on_score_updated(new_score: int) -> void:
	var label = get_node_or_null("ScoreLabel")
	if label:
		label.text = "Score: %d" % new_score

func _on_wave_changed(new_wave: int) -> void:
	var label = get_node_or_null("WaveLabel")
	if label:
		label.text = "Wave: %d" % new_wave

func _on_state_changed(new_state: GameManager.GameState) -> void:
	visible = (new_state == GameManager.GameState.PLAYING)
