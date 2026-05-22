## enemy.gd - Enemy AI that chases the player
extends CharacterBody2D

var enemy_type: int = SharedData.EnemyType.SLIME
var hp: float = 15.0
var speed: float = 55.0
var damage: float = 8.0
var xp_value: int = 5
var score_value: int = 10

var boss_attack_timer: float = 0.0
var boss_attack_interval: float = 3.0

var max_hp: float
var is_alive: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("enemy")
	_apply_config()

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Node2D

func _apply_config() -> void:
	var config = SharedData.ENEMY_CONFIGS.get(enemy_type, SharedData.ENEMY_CONFIGS[SharedData.EnemyType.SLIME])

	hp = config.hp
	max_hp = hp
	speed = config.speed
	damage = config.damage
	xp_value = config.xp_value
	score_value = config.score_value

	_create_sprite(config)

	if collision and collision.shape:
		(collision.shape as CircleShape2D).radius = config.size * 0.6

	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.tint_progress = config.color
		hp_bar.visible = false

	if enemy_type == SharedData.EnemyType.BOSS:
		boss_attack_timer = boss_attack_interval

func _create_sprite(config: Dictionary) -> void:
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)

	var size = int(config.size * 2 + 4)
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var center = size / 2
	var radius = config.size

	_draw_circle(img, center, center, radius, config.color)

	var eye_offset = int(radius * 0.3)
	_draw_circle(img, center - eye_offset, center - 2, 2, Color(0.9, 0.1, 0.1))
	_draw_circle(img, center + eye_offset, center - 2, 2, Color(0.9, 0.1, 0.1))

	match enemy_type:
		SharedData.EnemyType.BAT:
			_draw_circle(img, center - radius - 2, center - 2, int(radius * 0.6), config.color.darkened(0.1))
			_draw_circle(img, center + radius + 2, center - 2, int(radius * 0.6), config.color.darkened(0.1))
		SharedData.EnemyType.DEMON:
			_draw_circle(img, center - int(radius * 0.6), center - radius - 2, 3, Color(0.9, 0.6, 0.0))
			_draw_circle(img, center + int(radius * 0.6), center - radius - 2, 3, Color(0.9, 0.6, 0.0))
		SharedData.EnemyType.BOSS:
			for i in range(center - 6, center + 7, 4):
				_draw_circle(img, i, 3, 2, Color(1.0, 0.85, 0.0))

	sprite.texture = ImageTexture.create_from_image(img)

func _draw_circle(img: Image, cx: int, cy: int, r: int, color: Color) -> void:
	for x in range(cx - r, cx + r + 1):
		for y in range(cy - r, cy + r + 1):
			if Vector2(x - cx, y - cy).length() <= r:
				if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
					img.set_pixel(x, y, color)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity *= 0.85
	elif player_ref and is_instance_valid(player_ref):
		var direction = global_position.direction_to(player_ref.global_position)
		velocity = direction * speed

	if hp < max_hp:
		hp_bar.visible = true

	if enemy_type == SharedData.EnemyType.BOSS:
		_handle_boss_attack(delta)

	move_and_slide()

func _handle_boss_attack(delta: float) -> void:
	boss_attack_timer += delta
	if boss_attack_timer >= boss_attack_interval and player_ref and is_instance_valid(player_ref):
		boss_attack_timer = 0.0
		var dir = global_position.direction_to(player_ref.global_position)
		knockback_velocity = dir * speed * 3.0
		if sprite:
			sprite.modulate = Color(1.0, 0.3, 0.0)
			await get_tree().create_timer(0.15).timeout
			if is_alive and is_inside_tree():
				sprite.modulate = Color.WHITE

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if not is_alive:
		return
	hp -= amount
	hp_bar.value = hp

	if knockback_dir.length() > 0:
		var kb = 200.0 if enemy_type != SharedData.EnemyType.BOSS else 80.0
		knockback_velocity = knockback_dir.normalized() * kb

	if sprite:
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.06).timeout
		if is_alive and is_inside_tree():
			sprite.modulate = Color(1, 1, 1)

	if hp <= 0:
		_die()

func _die() -> void:
	is_alive = false
	remove_from_group("enemy")

	# Achievements
	var am = get_node_or_null("/root/GameScene/AchievementManager")
	if am:
		am.check_achievement("first_blood")
		if enemy_type == SharedData.EnemyType.BOSS:
			am.check_achievement("boss_slayer")

	GameManager.add_score(score_value)

	# Death particles
	var em = get_node_or_null("/root/GameScene/EffectsManager")
	if em:
		var config = SharedData.ENEMY_CONFIGS.get(enemy_type, {})
		em.spawn_death_burst(global_position, config.get("color", Color(1.0, 0.85, 0.2)))

	# Spawn XP
	_spawn_xp()

	queue_free()

func _spawn_xp() -> void:
	var xp_drop = Node2D.new()
	var xp_sprite = Sprite2D.new()

	var size = 16
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 7:
				var b = 1.0 - dist / 7.0
				img.set_pixel(x, y, Color(0.2 * b, 0.6 * b + 0.2, 1.0))
	xp_sprite.texture = ImageTexture.create_from_image(img)
	xp_sprite.scale = Vector2(1.2, 1.2)
	xp_drop.add_child(xp_sprite)

	var xp_collision = CollisionShape2D.new()
	xp_collision.shape = CircleShape2D.new()
	(xp_collision.shape as CircleShape2D).radius = 10
	xp_drop.add_child(xp_collision)

	xp_drop.set_script(preload("res://scripts/entities/xp_drop.gd"))
	xp_drop.global_position = global_position + Vector2(randf() - 0.5, randf() - 0.5) * 20
	xp_drop.value = xp_value
	get_parent().call_deferred("add_child", xp_drop)
