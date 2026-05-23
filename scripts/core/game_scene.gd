## game_scene.gd - Main gameplay scene with all systems integrated
extends Node2D

const ARENA_SIZE: float = 2000.0

var player: Node2D = null
var effects_manager: Node2D = null
var combo_manager_node: Node = null
var achievement_manager_node: Node = null
var skill_manager_node: Node = null
var level_up_ui: Control = null
var hud: Control = null
var pause_ui: Control = null
var combo_display: Control = null
var achievement_popup: Control = null
var skill_cooldown_bar: Control = null
var wave_announcer: CanvasLayer = null

func _ready() -> void:
	_setup_autoloads()
	_setup_scene()
	_connect_signals()
	GameManager.reset_run()
	GameManager.change_state(GameManager.GameState.PLAYING)

func _setup_autoloads() -> void:
	combo_manager_node = Node.new()
	combo_manager_node.name = "ComboManager"
	combo_manager_node.set_script(preload("res://scripts/systems/combo_manager.gd"))
	add_child(combo_manager_node)

	achievement_manager_node = Node.new()
	achievement_manager_node.name = "AchievementManager"
	achievement_manager_node.set_script(preload("res://scripts/systems/achievement_manager.gd"))
	add_child(achievement_manager_node)

	skill_manager_node = Node.new()
	skill_manager_node.name = "SkillManager"
	skill_manager_node.set_script(preload("res://scripts/core/skill_manager.gd"))
	add_child(skill_manager_node)

	effects_manager = Node2D.new()
	effects_manager.name = "EffectsManager"
	effects_manager.set_script(preload("res://scripts/core/effects_manager.gd"))
	add_child(effects_manager)

func _setup_scene() -> void:
	_create_arena()

	# Wave announcer
	wave_announcer = CanvasLayer.new()
	wave_announcer.name = "WaveAnnouncer"
	wave_announcer.layer = 10
	wave_announcer.set_script(preload("res://scripts/systems/wave_announcer.gd"))
	add_child(wave_announcer)

	player = _create_player()
	add_child(player)

	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.global_position = player.global_position
	player.add_child(camera)

	hud = _create_hud()
	add_child(hud)

	combo_display = combo_manager_node.create_combo_display(self)

	achievement_popup = _create_achievement_popup()
	add_child(achievement_popup)

	skill_cooldown_bar = _create_skill_cooldown_bar()
	add_child(skill_cooldown_bar)

	level_up_ui = _create_level_up_ui()
	add_child(level_up_ui)

	pause_ui = _create_pause_ui()
	add_child(pause_ui)

	var game_over_ui = _create_game_over_ui()
	game_over_ui.name = "GameOverUI"
	add_child(game_over_ui)

func _create_arena() -> void:
	var ground = ColorRect.new()
	ground.position = Vector2(-ARENA_SIZE / 2, -ARENA_SIZE / 2)
	ground.size = Vector2(ARENA_SIZE, ARENA_SIZE)
	ground.color = Color(0.06, 0.05, 0.10)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ground)

	var grid_color = Color(0.09, 0.08, 0.14)
	var tile = 64
	for x in range(-int(ARENA_SIZE / 2), int(ARENA_SIZE / 2), tile):
		var line = ColorRect.new()
		line.position = Vector2(x, -ARENA_SIZE / 2)
		line.size = Vector2(1, ARENA_SIZE)
		line.color = grid_color
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)

	for y in range(-int(ARENA_SIZE / 2), int(ARENA_SIZE / 2), tile):
		var line = ColorRect.new()
		line.position = Vector2(-ARENA_SIZE / 2, y)
		line.size = Vector2(ARENA_SIZE, 1)
		line.color = grid_color
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)

	var half = ARENA_SIZE / 2
	var wall_color = Color(0.2, 0.12, 0.3)
	var wall_thickness = 12
	var boundaries = [
		{"pos": Vector2(0, -half - wall_thickness / 2), "size": Vector2(ARENA_SIZE + wall_thickness * 2, wall_thickness)},
		{"pos": Vector2(0, half + wall_thickness / 2), "size": Vector2(ARENA_SIZE + wall_thickness * 2, wall_thickness)},
		{"pos": Vector2(-half - wall_thickness / 2, 0), "size": Vector2(wall_thickness, ARENA_SIZE + wall_thickness * 2)},
		{"pos": Vector2(half + wall_thickness / 2, 0), "size": Vector2(wall_thickness, ARENA_SIZE + wall_thickness * 2)},
	]
	for b in boundaries:
		var wall = StaticBody2D.new()
		wall.position = b.pos
		var cs = CollisionShape2D.new()
		cs.shape = RectangleShape2D.new()
		(cs.shape as RectangleShape2D).size = b.size
		wall.add_child(cs)
		var visual = ColorRect.new()
		visual.position = Vector2(-b.size.x / 2, -b.size.y / 2)
		visual.size = b.size
		visual.color = wall_color
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wall.add_child(visual)
		add_child(wall)

func _create_player() -> CharacterBody2D:
	var p = CharacterBody2D.new()
	p.name = "Player"
	p.global_position = Vector2(0, 0)

	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = _create_player_texture()
	sprite.scale = Vector2(1.5, 1.5)
	p.add_child(sprite)

	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = CircleShape2D.new()
	(collision.shape as CircleShape2D).radius = 12
	p.add_child(collision)

	var hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	var hitbox_collision = CollisionShape2D.new()
	hitbox_collision.shape = CircleShape2D.new()
	(hitbox_collision.shape as CircleShape2D).radius = 14
	hitbox.add_child(hitbox_collision)
	hitbox.body_entered.connect(_on_enemy_contact)
	p.add_child(hitbox)

	var hp_bar = TextureProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.tint_progress = Color(0.2, 0.9, 0.3)
	hp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	hp_bar.custom_minimum_size = Vector2(30, 5)
	hp_bar.position = Vector2(0, -22)
	p.add_child(hp_bar)

	p.set_script(preload("res://scripts/core/player.gd"))
	return p

func _create_player_texture() -> ImageTexture:
	var size = 32
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 12:
				img.set_pixel(x, y, Color(0.2, 0.4, 0.9))
			elif dist <= 14:
				img.set_pixel(x, y, Color(0.15, 0.3, 0.7))
	img.set_pixel(12, 13, Color(1.0, 1.0, 1.0))
	img.set_pixel(20, 13, Color(1.0, 1.0, 1.0))
	for x in range(10, 23):
		for y in range(3, 10):
			if Vector2(x - 16, y - 6).length() <= 8:
				img.set_pixel(x, y, Color(0.5, 0.5, 0.55))
	return ImageTexture.create_from_image(img)

func _create_hud() -> Control:
	var hud_node = Control.new()
	hud_node.name = "HUD"
	hud_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.position = Vector2(20, 15)
	wave_label.custom_minimum_size = Vector2(200, 30)
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.text = "Wave: 0"
	hud_node.add_child(wave_label)

	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(20, 45)
	score_label.custom_minimum_size = Vector2(200, 30)
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.text = "Score: 0"
	hud_node.add_child(score_label)

	var xp_bar = TextureProgressBar.new()
	xp_bar.name = "XPBar"
	xp_bar.position = Vector2(20, 80)
	xp_bar.custom_minimum_size = Vector2(200, 12)
	xp_bar.max_value = 10
	xp_bar.value = 0
	xp_bar.tint_progress = Color(0.3, 0.6, 1.0)
	xp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	hud_node.add_child(xp_bar)

	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.position = Vector2(20, 95)
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.text = "Lv.1"
	hud_node.add_child(level_label)

	hud_node.set_script(preload("res://scripts/ui/hud.gd"))
	return hud_node

func _create_skill_cooldown_bar() -> Control:
	var panel = Control.new()
	panel.name = "SkillCooldownBar"
	panel.position = Vector2(600, 640)
	panel.custom_minimum_size = Vector2(120, 40)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.7)
	bg.position = Vector2(0, 0)
	bg.size = Vector2(120, 30)
	panel.add_child(bg)

	var fill = ColorRect.new()
	fill.name = "SkillFill"
	fill.color = Color(1.0, 0.5, 0.1)
	fill.position = Vector2(0, 0)
	fill.size = Vector2(120, 30)
	panel.add_child(fill)

	var label = Label.new()
	label.name = "SkillLabel"
	label.position = Vector2(0, 0)
	label.custom_minimum_size = Vector2(120, 30)
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "🔥 技能 [空格]"
	panel.add_child(label)

	if skill_manager_node:
		skill_manager_node.cooldown_updated.connect(func(current, max_cd):
			var pct = 1.0 - (current / max_cd)
			fill.size.x = 120.0 * pct
			if current > 0:
				label.text = "⏳ %.1fs" % current
				fill.color = Color(0.4, 0.4, 0.4)
			else:
				label.text = "🔥 技能 [空格]"
				fill.color = Color(1.0, 0.5, 0.1)
		)

	return panel

func _create_achievement_popup() -> Control:
	var panel = Control.new()
	panel.name = "AchievementPopup"
	panel.position = Vector2(880, 20)
	panel.custom_minimum_size = Vector2(320, 60)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.visible = false

	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)

	var border = ColorRect.new()
	border.color = Color(1.0, 0.85, 0.0)
	border.position = Vector2(0, 0)
	border.custom_minimum_size = Vector2(320, 3)
	panel.add_child(border)

	var icon_label = Label.new()
	icon_label.name = "IconLabel"
	icon_label.position = Vector2(10, 8)
	icon_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(icon_label)

	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.position = Vector2(50, 5)
	name_label.custom_minimum_size = Vector2(260, 22)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	panel.add_child(name_label)

	var desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.position = Vector2(50, 28)
	desc_label.custom_minimum_size = Vector2(260, 20)
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	panel.add_child(desc_label)

	if achievement_manager_node:
		achievement_manager_node.achievement_unlocked.connect(func(_id, name, desc, icon):
			icon_label.text = icon
			name_label.text = "🏆 %s" % name
			desc_label.text = desc
			panel.visible = true
			panel.position.x = 880
			var tween = create_tween()
			tween.tween_property(panel, "position:x", 850, 0.3).set_ease(Tween.EASE_OUT)
			await get_tree().create_timer(3.0).timeout
			var tween2 = create_tween()
			tween2.tween_property(panel, "position:x", 880, 0.3).set_ease(Tween.EASE_IN)
			tween2.tween_callback(func(): panel.visible = false)
		)

	return panel

func _create_level_up_ui() -> Control:
	var panel = Control.new()
	panel.name = "LevelUpUI"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-250, -150)
	panel.custom_minimum_size = Vector2(500, 300)
	panel.visible = false

	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)

	var border = ColorRect.new()
	border.color = Color(0.3, 0.7, 1.0)
	border.position = Vector2(0, 0)
	border.custom_minimum_size = Vector2(500, 4)
	panel.add_child(border)

	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "⬆ LEVEL UP! ⬆"
	title.position = Vector2(20, 15)
	title.custom_minimum_size = Vector2(460, 40)
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	var container = VBoxContainer.new()
	container.name = "UpgradeContainer"
	container.position = Vector2(30, 70)
	container.custom_minimum_size = Vector2(440, 200)
	container.add_theme_constant_override("separation", 10)
	panel.add_child(container)

	panel.set_script(preload("res://scripts/ui/level_up_ui.gd"))
	return panel

func _create_pause_ui() -> Control:
	var panel = Control.new()
	panel.name = "PauseUI"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-150, -100)
	panel.custom_minimum_size = Vector2(300, 200)
	panel.visible = false

	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg)

	var title = Label.new()
	title.text = "⏸ 暂停"
	title.position = Vector2(20, 20)
	title.custom_minimum_size = Vector2(260, 40)
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	var resume_btn = Button.new()
	resume_btn.name = "ResumeButton"
	resume_btn.text = "继续游戏"
	resume_btn.position = Vector2(50, 80)
	resume_btn.custom_minimum_size = Vector2(200, 40)
	resume_btn.add_theme_font_size_override("font_size", 18)
	panel.add_child(resume_btn)

	var restart_btn = Button.new()
	restart_btn.name = "RestartButton"
	restart_btn.text = "重新开始"
	restart_btn.position = Vector2(50, 130)
	restart_btn.custom_minimum_size = Vector2(200, 40)
	restart_btn.add_theme_font_size_override("font_size", 18)
	panel.add_child(restart_btn)

	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
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

	if achievement_manager_node:
		GameManager.level_up_triggered.connect(func(level):
			achievement_manager_node.check_level(level)
		)
		GameManager.score_updated.connect(func(score):
			achievement_manager_node.check_score(score)
		)

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

func _on_resume() -> void:
	if pause_ui:
		pause_ui.visible = false
	GameManager.change_state(GameManager.GameState.PLAYING)

func _on_restart() -> void:
	if pause_ui:
		pause_ui.visible = false
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.change_state(GameManager.GameState.PAUSED)
			if pause_ui:
				pause_ui.visible = true
		elif GameManager.current_state == GameManager.GameState.PAUSED:
			_on_resume()

	if event.is_action_pressed("use_skill"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if skill_manager_node:
				skill_manager_node.try_use_skill()
