## game_scene.gd - Main gameplay scene
## Manages the game loop, player, enemies, waves, UI, and level-up
extends Node2D

var player: Node2D = null
var level_up_ui: Control = null
var hud: Control = null

func _ready() -> void:
	_setup_scene()
	_connect_signals()
	GameManager.reset_run()
	GameManager.change_state(GameManager.GameState.PLAYING)

func _setup_scene() -> void:
	# Create player
	player = _create_player()
	add_child(player)
	
	# Create camera
	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.global_position = player.global_position
	player.add_child(camera)
	camera.set_owner(player)
	
	# Create HUD
	hud = _create_hud()
	add_child(hud)
	
	# Create Level Up UI
	level_up_ui = _create_level_up_ui()
	add_child(level_up_ui)
	
	# Create Game Over UI (hidden initially)
	var game_over_ui = _create_game_over_ui()
	game_over_ui.name = "GameOverUI"
	add_child(game_over_ui)

func _create_player() -> CharacterBody2D:
	var p = CharacterBody2D.new()
	p.name = "Player"
	p.global_position = Vector2(0, 0)
	
	# Sprite
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = _create_player_texture()
	sprite.scale = Vector2(1.5, 1.5)
	p.add_child(sprite)
	
	# Collision
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = CircleShape2D.new()
	(collision.shape as CircleShape2D).radius = 12
	p.add_child(collision)
	
	# Damage hitbox (area for enemy contact damage)
	var hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	var hitbox_collision = CollisionShape2D.new()
	hitbox_collision.shape = CircleShape2D.new()
	(hitbox_collision.shape as CircleShape2D).radius = 14
	hitbox.add_child(hitbox_collision)
	hitbox.body_entered.connect(_on_enemy_contact)
	p.add_child(hitbox)
	
	# HP bar
	var hp_bar = TextureProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.tint_progress = Color(0.2, 0.9, 0.3)
	hp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	hp_bar.custom_minimum_size = Vector2(30, 5)
	hp_bar.position = Vector2(0, -22)
	p.add_child(hp_bar)
	
	# Load player script
	p.set_script(preload("res://scripts/core/player.gd"))
	
	return p

func _create_player_texture() -> ImageTexture:
	var size = 32
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Body (blue knight)
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 12:
				img.set_pixel(x, y, Color(0.2, 0.4, 0.9))
			elif dist <= 14:
				img.set_pixel(x, y, Color(0.15, 0.3, 0.7))
	
	# Eyes
	img.set_pixel(12, 13, Color(1.0, 1.0, 1.0))
	img.set_pixel(20, 13, Color(1.0, 1.0, 1.0))
	
	# Helmet top
	for x in range(10, 23):
		for y in range(3, 10):
			if Vector2(x - 16, y - 6).length() <= 8:
				img.set_pixel(x, y, Color(0.5, 0.5, 0.55))
	
	return ImageTexture.create_from_image(img)

func _create_hud() -> Control:
	var hud = Control.new()
	hud.name = "HUD"
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Wave label
	var wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.position = Vector2(20, 15)
	wave_label.custom_minimum_size = Vector2(200, 30)
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.text = "Wave: 0"
	hud.add_child(wave_label)
	
	# Score label
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(20, 45)
	score_label.custom_minimum_size = Vector2(200, 30)
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.text = "Score: 0"
	hud.add_child(score_label)
	
	# XP bar
	var xp_bar = TextureProgressBar.new()
	xp_bar.name = "XPBar"
	xp_bar.position = Vector2(20, 80)
	xp_bar.custom_minimum_size = Vector2(200, 12)
	xp_bar.max_value = 10
	xp_bar.value = 0
	xp_bar.tint_progress = Color(0.3, 0.6, 1.0)
	xp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	hud.add_child(xp_bar)
	
	# Level label
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.position = Vector2(20, 95)
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.text = "Lv.1"
	hud.add_child(level_label)
	
	# Load HUD script
	hud.set_script(preload("res://scripts/ui/hud.gd"))
	
	return hud

func _create_level_up_ui() -> Control:
	var panel = Control.new()
	panel.name = "LevelUpUI"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-250, -150)
	panel.custom_minimum_size = Vector2(500, 300)
	panel.visible = false
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)
	
	# Border
	var border = ColorRect.new()
	border.color = Color(0.3, 0.7, 1.0)
	border.position = Vector2(0, 0)
	border.custom_minimum_size = Vector2(500, 4)
	panel.add_child(border)
	
	# Title
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "⬆ LEVEL UP! ⬆"
	title.position = Vector2(20, 15)
	title.custom_minimum_size = Vector2(460, 40)
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	
	# Upgrade buttons container
	var container = VBoxContainer.new()
	container.name = "UpgradeContainer"
	container.position = Vector2(30, 70)
	container.custom_minimum_size = Vector2(440, 200)
	container.add_theme_constant_override("separation", 10)
	panel.add_child(container)
	
	# Load level up script
	panel.set_script(preload("res://scripts/ui/level_up_ui.gd"))
	
	return panel

func _create_game_over_ui() -> Control:
	var panel = Control.new()
	panel.name = "GameOverUI"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-200, -120)
	panel.custom_minimum_size = Vector2(400, 240)
	panel.visible = false
	
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.02, 0.02, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)
	
	var title = Label.new()
	title.text = "💀 GAME OVER"
	title.position = Vector2(20, 15)
	title.custom_minimum_size = Vector2(360, 45)
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	
	var score_label = Label.new()
	score_label.name = "FinalScoreLabel"
	score_label.text = "Score: 0"
	score_label.position = Vector2(20, 75)
	score_label.custom_minimum_size = Vector2(360, 30)
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(score_label)
	
	var wave_label = Label.new()
	wave_label.name = "FinalWaveLabel"
	wave_label.text = "Wave: 0"
	wave_label.position = Vector2(20, 110)
	wave_label.custom_minimum_size = Vector2(360, 30)
	wave_label.add_theme_font_size_override("font_size", 18)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(wave_label)
	
	var restart_btn = Button.new()
	restart_btn.name = "RestartButton"
	restart_btn.text = "再来一局"
	restart_btn.position = Vector2(100, 160)
	restart_btn.custom_minimum_size = Vector2(200, 45)
	restart_btn.add_theme_font_size_override("font_size", 20)
	panel.add_child(restart_btn)
	
	panel.set_script(preload("res://scripts/ui/game_over_ui.gd"))
	
	return panel

func _connect_signals() -> void:
	GameManager.level_up_triggered.connect(_on_level_up)
	GameManager.game_over_triggered.connect(_on_game_over)

func _on_enemy_contact(body: Node) -> void:
	if body.is_in_group("enemy"):
		var enemy = body as Node2D
		if enemy and player and player.has_method("take_damage"):
			var damage = enemy.get("damage") if enemy.has_method("get") else 10
			player.take_damage(damage)

func _on_level_up(level: int) -> void:
	if level_up_ui:
		level_up_ui.visible = true
		level_up_ui._show_upgrades()

func _on_game_over(final_score: int, final_wave: int) -> void:
	var game_over_ui = get_node_or_null("GameOverUI")
	if game_over_ui:
		game_over_ui.visible = true
		var score_label = game_over_ui.get_node_or_null("FinalScoreLabel")
		var wave_label = game_over_ui.get_node_or_null("FinalWaveLabel")
		if score_label:
			score_label.text = "Score: %d" % final_score
		if wave_label:
			wave_label.text = "Wave: %d" % final_wave

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.change_state(GameManager.GameState.PAUSED)
		elif GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.change_state(GameManager.GameState.PLAYING)
