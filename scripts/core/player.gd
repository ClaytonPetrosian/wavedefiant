## Player.gd - Player character controller
## Handles movement, auto-attack, health, XP collection
extends CharacterBody2D

const BASE_SPEED: float = 180.0
const BASE_HP: float = 100.0
const XP_MAGNET_RANGE: float = 120.0
const XP_COLLECT_SPEED: float = 400.0

# Stats (modified by upgrades)
@export var speed: float = BASE_SPEED
@export var max_hp: float = BASE_HP
@export var attack_interval: float = 0.8
@export var attack_range: float = 220.0
@export var attack_damage: float = 12.0
@export var projectile_count: int = 1

var hp: float = BASE_HP
var is_alive: bool = true
var current_attack_timer: float = 0.0

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
		if dist < XP_MAGNET_RANGE:
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
	var projectile_scene = preload("res://scripts/entities/projectile.gd")
	var projectile = Area2D.new()
	
	# Visual
	var proj_sprite = Sprite2D.new()
	proj_sprite.texture = _create_circle_texture(6, Color(1.0, 0.9, 0.3))
	proj_sprite.scale = Vector2(1.5, 1.5)
	projectile.add_child(proj_sprite)
	
	# Collision
	var proj_collision = CollisionShape2D.new()
	proj_collision.shape = CircleShape2D.new()
	(proj_collision.shape as CircleShape2D).radius = 8
	projectile.add_child(proj_collision)
	
	projectile.global_position = global_position
	projectile.target = target
	projectile.damage = attack_damage
	projectile.speed = 350.0
	
	get_parent().call_deferred("add_child", projectile)

func _create_circle_texture(radius: int, color: Color) -> ImageTexture:
	var size = radius * 2 + 1
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x - radius, y - radius).length()
			if dist <= radius:
				img.set_pixel(x, y, color)
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	hp -= amount
	# Flash red
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	if is_alive and is_inside_tree():
		sprite.modulate = Color.WHITE
	
	if hp <= 0:
		hp = 0
		_die()

func _die() -> void:
	is_alive = false
	GameManager.trigger_game_over()
	queue_free()

func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)
