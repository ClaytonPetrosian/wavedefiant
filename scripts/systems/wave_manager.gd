## wave_manager.gd - Spawns enemies in waves, scales difficulty
## Auto-starts when game begins, spawns increasingly harder waves
extends Node

# Use shared enemy type enum
const EnemyType = SharedData.EnemyType

const SPAWN_MARGIN: float = 400.0  # Pixels outside camera view

var wave_active: bool = false
var enemies_remaining: int = 0
var wave_timer: float = 0.0
var wave_delay: float = 3.0  # Seconds between waves
var spawn_timer: float = 0.0
var spawn_interval: float = 0.5
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0

var current_wave_config: Dictionary = {}
var player_ref: Node2D = null

# Wave configs: each wave has enemy types, counts, and intervals
func _ready() -> void:
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.state_changed.connect(_on_state_changed)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Find player if not yet referenced
	if not player_ref:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0] as Node2D
	
	# Start first wave
	if not wave_active and enemies_to_spawn == 0 and enemies_spawned == 0 and enemies_remaining == 0:
		start_wave(1)
		return
	
	# Between waves delay
	if not wave_active:
		wave_timer += delta
		if wave_timer >= wave_delay:
			wave_timer = 0.0
			start_wave(GameManager.current_wave + 1)
		return
	
	# Spawn enemies
	if enemies_spawned < enemies_to_spawn:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			_spawn_enemy()
			enemies_spawned += 1
	
	# Check if wave is cleared
	if enemies_spawned >= enemies_to_spawn and enemies_remaining <= 0:
		wave_active = false
		wave_timer = 0.0

func start_wave(wave_number: int) -> void:
	wave_active = true
	enemies_spawned = 0
	spawn_timer = 0.0
	
	# Scale difficulty
	var wave_data = _get_wave_config(wave_number)
	enemies_to_spawn = wave_data.count
	spawn_interval = wave_data.interval
	
	current_wave_config = wave_data
	enemies_remaining = enemies_to_spawn
	
	GameManager.add_wave()

func _get_wave_config(wave: int) -> Dictionary:
	# Progressive difficulty
	var base_count = 5 + wave * 3
	var base_interval = max(0.15, 0.5 - wave * 0.02)
	
	var config = {
		"count": base_count,
		"interval": base_interval,
		"types": []
	}
	
	# Add enemy types based on wave
	config.types.append({"type": EnemyType.SLIME, "weight": 60})
	
	if wave >= 2:
		config.types.append({"type": EnemyType.BAT, "weight": 30})
	
	if wave >= 4:
		config.types.append({"type": EnemyType.SKELETON, "weight": 20})
	
	if wave >= 7:
		config.types.append({"type": EnemyType.DEMON, "weight": 10})
	
	# Boss every 5 waves
	if wave % 5 == 0:
		config.types.append({"type": EnemyType.BOSS, "weight": 5})
		config.count += 1
	
	return config

func _spawn_enemy() -> void:
	if not player_ref:
		return
	
	var enemy_scene = preload("res://scenes/battle/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Pick random type based on weights
	var type = _pick_enemy_type()
	enemy.enemy_type = type as Enemy.EnemyType
	
	# Scale stats with wave
	var wave_scale = 1.0 + (GameManager.current_wave - 1) * 0.15
	enemy.hp *= wave_scale
	enemy.max_hp = enemy.hp
	enemy.damage *= (1.0 + (GameManager.current_wave - 1) * 0.08)
	enemy.xp_value = int(enemy.xp_value * (1.0 + GameManager.current_wave * 0.1))
	
	# Spawn position: random point outside camera view
	var camera = get_viewport().get_camera_2d()
	var spawn_pos = _get_spawn_position(camera)
	enemy.global_position = spawn_pos
	
	call_deferred("add_child", enemy)
	enemies_remaining += 1
	
	# Track enemy death
	enemy.tree_exiting.connect(func(): 
		if is_inside_tree():
			enemies_remaining -= 1
	)

func _pick_enemy_type() -> int:
	var types = current_wave_config.get("types", [])
	var total_weight = 0
	for t in types:
		total_weight += t.weight
	
	var roll = randf() * total_weight
	var cumulative = 0.0
	for t in types:
		cumulative += t.weight
		if roll <= cumulative:
			return t.type
	
	return SharedData.EnemyType.SLIME

func _get_spawn_position(camera: Camera2D) -> Vector2:
	if not camera:
		return Vector2(randf() * 800, randf() * 600)
	
	var center = camera.global_position
	var viewport_size = get_viewport_rect().size
	var margin = SPAWN_MARGIN
	
	# Pick random edge
	var edge = randi() % 4
	var pos = Vector2.ZERO
	
	match edge:
		0:  # Top
			pos.x = center.x + randf_range(-viewport_size.x / 2 - margin, viewport_size.x / 2 + margin)
			pos.y = center.y - viewport_size.y / 2 - margin + randf_range(0, 100)
		1:  # Bottom
			pos.x = center.x + randf_range(-viewport_size.x / 2 - margin, viewport_size.x / 2 + margin)
			pos.y = center.y + viewport_size.y / 2 + margin - randf_range(0, 100)
		2:  # Left
			pos.x = center.x - viewport_size.x / 2 - margin + randf_range(0, 100)
			pos.y = center.y + randf_range(-viewport_size.y / 2 - margin, viewport_size.y / 2 + margin)
		3:  # Right
			pos.x = center.x + viewport_size.x / 2 + margin - randf_range(0, 100)
			pos.y = center.y + randf_range(-viewport_size.y / 2 - margin, viewport_size.y / 2 + margin)
	
	return pos

func _on_wave_changed(new_wave: int) -> void:
	pass

func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.PLAYING:
		pass  # Wave system handles itself
