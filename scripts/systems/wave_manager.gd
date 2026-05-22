## wave_manager.gd - Spawns enemies in waves, scales difficulty
extends Node

const EnemyType = SharedData.EnemyType

var wave_active: bool = false
var enemies_remaining: int = 0
var wave_timer: float = 0.0
var wave_delay: float = 3.0
var spawn_timer: float = 0.0
var spawn_interval: float = 0.5
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var player_ref: Node2D = null

func _ready() -> void:
	GameManager.wave_changed.connect(_on_wave_changed)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	if not player_ref:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0] as Node2D

	if not wave_active and enemies_to_spawn == 0 and enemies_spawned == 0 and enemies_remaining == 0:
		start_wave(1)
		return

	if not wave_active:
		wave_timer += delta
		if wave_timer >= wave_delay:
			wave_timer = 0.0
			start_wave(GameManager.current_wave + 1)
		return

	if enemies_spawned < enemies_to_spawn:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			_spawn_enemy()
			enemies_spawned += 1

	if enemies_spawned >= enemies_to_spawn and enemies_remaining <= 0:
		wave_active = false
		wave_timer = 0.0
		# Wave achievements
		var am = get_node_or_null("/root/GameScene/AchievementManager")
		if am:
			am.check_wave(GameManager.current_wave)

func start_wave(wave_number: int) -> void:
	wave_active = true
	enemies_spawned = 0
	spawn_timer = 0.0

	var wave_data = _get_wave_config(wave_number)
	enemies_to_spawn = wave_data.count
	spawn_interval = wave_data.interval

	enemies_remaining = enemies_to_spawn
	GameManager.add_wave()

func _get_wave_config(wave: int) -> Dictionary:
	var base_count = 5 + wave * 3
	var base_interval = max(0.15, 0.5 - wave * 0.02)

	var config = {
		"count": base_count,
		"interval": base_interval,
		"types": []
	}

	config.types.append({"type": EnemyType.SLIME, "weight": 60})
	if wave >= 2:
		config.types.append({"type": EnemyType.BAT, "weight": 30})
	if wave >= 4:
		config.types.append({"type": EnemyType.SKELETON, "weight": 20})
	if wave >= 7:
		config.types.append({"type": EnemyType.DEMON, "weight": 10})
	if wave % 5 == 0:
		config.types.append({"type": EnemyType.BOSS, "weight": 5})
		config.count += 1

	return config

func _spawn_enemy() -> void:
	if not player_ref:
		return

	var enemy_scene = load("res://scenes/battle/enemy.tscn")
	var enemy = enemy_scene.instantiate()

	var type = _pick_enemy_type()
	enemy.enemy_type = type

	var wave_scale = 1.0 + (GameManager.current_wave - 1) * 0.15
	enemy.hp *= wave_scale
	enemy.max_hp = enemy.hp
	enemy.damage *= (1.0 + (GameManager.current_wave - 1) * 0.08)
	enemy.xp_value = int(enemy.xp_value * (1.0 + GameManager.current_wave * 0.1))

	var camera = get_viewport().get_camera_2d()
	var spawn_pos = _get_spawn_position(camera)
	enemy.global_position = spawn_pos

	call_deferred("add_child", enemy)
	enemies_remaining += 1

	enemy.tree_exiting.connect(func():
		if is_inside_tree():
			enemies_remaining -= 1
	)

func _pick_enemy_type() -> int:
	var types = _get_wave_config(GameManager.current_wave).types
	var total_weight = 0
	for t in types:
		total_weight += t.weight

	var roll = randf() * total_weight
	var cumulative = 0.0
	for t in types:
		cumulative += t.weight
		if roll <= cumulative:
			return t.type

	return EnemyType.SLIME

func _get_spawn_position(camera: Camera2D) -> Vector2:
	if not camera:
		return Vector2(randf() * 800, randf() * 600)

	var center = camera.global_position
	var vs = get_viewport_rect().size
	var margin = 400.0

	match randi() % 4:
		0:
			return Vector2(center.x + randf_range(-vs.x/2 - margin, vs.x/2 + margin), center.y - vs.y/2 - margin + randf_range(0, 100))
		1:
			return Vector2(center.x + randf_range(-vs.x/2 - margin, vs.x/2 + margin), center.y + vs.y/2 + margin - randf_range(0, 100))
		2:
			return Vector2(center.x - vs.x/2 - margin + randf_range(0, 100), center.y + randf_range(-vs.y/2 - margin, vs.y/2 + margin))
		3:
			return Vector2(center.x + vs.x/2 + margin - randf_range(0, 100), center.y + randf_range(-vs.y/2 - margin, vs.y/2 + margin))

	return center

func _on_wave_changed(_new_wave: int) -> void:
	pass
