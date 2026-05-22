## enemy.gd - Enemy AI that chases the player
## Reads config from SharedData for stats
extends CharacterBody2D

var enemy_type: int = SharedData.EnemyType.SLIME
var hp: float = 15.0
var speed: float = 55.0
var damage: float = 8.0
var xp_value: int = 5
var score_value: int = 10

var max_hp: float
var is_alive: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var player_ref: Node2D = null
var hit_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("enemy")
	_apply_config()
	
	# Find player
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
	
	# Create sprite
	_create_sprite(config)
	
	# Update collision
	if collision and collision.shape:
		(collision.shape as CircleShape2D).radius = config.size * 0.6
	
	# Update HP bar
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.tint_progress = config.color
		hp_bar.visible = false

func _create_sprite(config: Dictionary) -> void:
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	var size = int(config.size * 2 + 4)
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = size / 2
	var radius = config.size
	
	# Body
	_draw_circle(img, center, center, radius, config.color)
	
	# Eyes
	var eye_offset = int(radius * 0.3)
	_draw_circle(img, center - eye_offset, center - 2, 2, Color(0.9, 0.1, 0.1))
	_draw_circle(img, center + eye_offset, center - 2, 2, Color(0.9, 0.1, 0.1))
	
	# Type-specific features
	match enemy_type:
		SharedData.EnemyType.BAT:
			# Wings
			_draw_circle(img, center - radius - 2, center - 2, int(radius * 0.6), config.color.darkened(0.1))
			_draw_circle(img, center + radius + 2, center - 2, int(radius * 0.6), config.color.darkened(0.1))
		SharedData.EnemyType.DEMON:
			# Horns
			_draw_circle(img, center - int(radius * 0.6), center - radius - 2, 3, Color(0.9, 0.6, 0.0))
			_draw_circle(img, center + int(radius * 0.6), center - radius - 2, 3, Color(0.9, 0.6, 0.0))
		SharedData.EnemyType.BOSS:
			# Crown
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
	
	hit_cooldown -= delta
	
	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity *= 0.85
	elif player_ref and is_instance_valid(player_ref):
		var direction = global_position.direction_to(player_ref.global_position)
		velocity = direction * speed
	
	# Show HP bar when damaged
	if hp < max_hp:
		hp_bar.visible = true
	
	move_and_slide()

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if not is_alive:
		return
	hp -= amount
	hp_bar.value = hp
	
	if knockback_dir.length() > 0:
		knockback_velocity = knockback_dir.normalized() * 200.0
	
	# Flash white
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
	GameManager.add_score(score_value)
	
	# Spawn XP drop
	var xp_scene = load("res://scenes/battle/xp_drop.tscn") if ResourceLoader.exists("res://scenes/battle/xp_drop.tscn") else null
	
	if not xp_scene:
		# Create XP drop programmatically
		var xp_drop = Node2D.new()
		var xp_sprite = Sprite2D.new()
		
		var size = 16
		var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		for x in range(size):
			for y in range(size):
				var dist = Vector2(x - 8, y - 8).length()
				if dist <= 7:
					var brightness = 1.0 - dist / 7.0
					img.set_pixel(x, y, Color(0.2 * brightness, 0.6 * brightness + 0.2, 1.0))
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
	else:
		var drop = xp_scene.instantiate()
		drop.global_position = global_position + Vector2(randf() - 0.5, randf() - 0.5) * 20
		drop.value = xp_value
		get_parent().call_deferred("add_child", drop)
	
	queue_free()
