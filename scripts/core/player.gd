## player.gd - Player character controller
## Handles movement, auto-attack, health, XP collection, invincibility frames
extends CharacterBody2D

const BASE_SPEED: float = 180.0
const BASE_HP: float = 100.0
const XP_MAGNET_RANGE: float = 120.0
const XP_COLLECT_SPEED: float = 400.0
const INVINCIBLE_DURATION: float = 0.5

# Stats (modified by upgrades)
var speed: float = BASE_SPEED
var max_hp: float = BASE_HP
var attack_interval: float = 0.8
var attack_range: float = 220.0
var attack_damage: float = 12.0
var projectile_count: int = 1
var xp_magnet_range: float = XP_MAGNET_RANGE
var crit_chance: float = 0.05  # 5% base crit chance
var crit_multiplier: float = 2.0

var hp: float = BASE_HP
var is_alive: bool = true
var is_invincible: bool = false
var current_attack_timer: float = 0.0
var regen_per_second: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hp = max_hp
	add_to_group("player")
	current_attack_timer = 0.0
	hp_bar.max_value = max_hp
	hp_bar.value = hp

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	if GameManager.current_state == GameManager.GameState.PLAYING:
		_handle_movement(delta)
		_handle_xp_magnet(delta)
		_handle_auto_attack(delta)
		_handle_regen(delta)

	hp_bar.value = hp

func _handle_movement(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _handle_xp_magnet(delta: float) -> void:
	var xp_drops = get_tree().get_nodes_in_group("xp_drop")
	for drop in xp_drops:
		if not is_instance_valid(drop):
			continue
		var dist = global_position.distance_to(drop.global_position)
		if dist < xp_magnet_range:
			var dir = global_position.direction_to(drop.global_position)
			drop.global_position += dir * XP_COLLECT_SPEED * delta
		if dist < 16.0:
			drop._collect()

func _handle_auto_attack(delta: float) -> void:
	current_attack_timer += delta
	if current_attack_timer >= attack_interval:
		var targets = _find_nearest_enemies()
		if targets.size() > 0:
			current_attack_timer = 0.0
			for target in targets:
				_fire_projectile(target)

func _find_nearest_enemies() -> Array:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var enemies_with_dist = []

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < attack_range:
			enemies_with_dist.append({"node": enemy, "dist": dist})

	enemies_with_dist.sort_custom(func(a, b): return a.dist < b.dist)

	var result = []
	for i in range(min(projectile_count, enemies_with_dist.size())):
		result.append(enemies_with_dist[i].node)

	return result

func _fire_projectile(target: Node2D) -> void:
	var projectile = Area2D.new()
	projectile.global_position = global_position

	# Visual - glowing orb
	var proj_sprite = Sprite2D.new()
	proj_sprite.texture = _create_projectile_texture()
	proj_sprite.scale = Vector2(1.2, 1.2)
	projectile.add_child(proj_sprite)

	# Light glow effect
	var glow = Sprite2D.new()
	#glow.texture = _create_glow_texture()
	#glow.scale = Vector2(2.0, 2.0)
	#projectile.add_child(glow)

	# Collision
	var proj_collision = CollisionShape2D.new()
	proj_collision.shape = CircleShape2D.new()
	(proj_collision.shape as CircleShape2D).radius = 8
	projectile.add_child(proj_collision)

	projectile.target = target
	projectile.damage = attack_damage
	projectile.crit_chance = crit_chance
	projectile.crit_multiplier = crit_multiplier
	projectile.speed = 350.0
	projectile.set_script(preload("res://scripts/entities/projectile.gd"))

	get_parent().call_deferred("add_child", projectile)

func _create_projectile_texture() -> ImageTexture:
	var size = 16
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 5:
				var brightness = 1.0 - dist / 5.0
				img.set_pixel(x, y, Color(1.0, 0.9, 0.3, brightness))
			elif dist <= 7:
				var brightness = 0.4 * (1.0 - (dist - 5) / 2.0)
				img.set_pixel(x, y, Color(1.0, 0.7, 0.1, brightness))
	return ImageTexture.create_from_image(img)

func _handle_regen(delta: float) -> void:
	if regen_per_second > 0 and hp < max_hp:
		hp = min(hp + regen_per_second * delta, max_hp)

func take_damage(amount: float) -> void:
	if not is_alive or is_invincible:
		return

	is_invincible = true
	hp -= amount

	# Flash red
	sprite.modulate = Color(1, 0.3, 0.3)

	# Screen shake via effects manager
	var em = get_node_or_null("/root/GameScene/EffectsManager")
	if em:
		em.screen_shake(3.0, 0.1)

	await get_tree().create_timer(INVINCIBLE_DURATION).timeout
	if is_alive and is_inside_tree():
		sprite.modulate = Color.WHITE
		is_invincible = false

	if hp <= 0:
		hp = 0
		_die()

func _die() -> void:
	is_alive = false
	GameManager.trigger_game_over()
	queue_free()

func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)
