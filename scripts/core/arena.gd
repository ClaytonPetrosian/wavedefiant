## arena.gd - Battle arena with boundaries and background
## Creates a large play area with visual boundaries and decorative elements
extends Node2D

const ARENA_SIZE: float = 2400.0
const TILE_SIZE: int = 64

func _ready() -> void:
	_create_background()
	_create_boundaries()
	_create_decorations()

func _create_background() -> void:
	# Dark ground
	var ground = ColorRect.new()
	ground.position = Vector2(-ARENA_SIZE / 2, -ARENA_SIZE / 2)
	ground.size = Vector2(ARENA_SIZE, ARENA_SIZE)
	ground.color = Color(0.08, 0.07, 0.12)
	ground.name = "Ground"
	add_child(ground)
	
	# Grid pattern (subtle)
	var grid_color = Color(0.12, 0.11, 0.18)
	for x in range(-int(ARENA_SIZE / 2), int(ARENA_SIZE / 2), TILE_SIZE):
		var line = ColorRect.new()
		line.position = Vector2(x, -ARENA_SIZE / 2)
		line.size = Vector2(1, ARENA_SIZE)
		line.color = grid_color
		add_child(line)
	
	for y in range(-int(ARENA_SIZE / 2), int(ARENA_SIZE / 2), TILE_SIZE):
		var line = ColorRect.new()
		line.position = Vector2(-ARENA_SIZE / 2, y)
		line.size = Vector2(ARENA_SIZE, 1)
		line.color = grid_color
		add_child(line)

func _create_boundaries() -> void:
	var half = ARENA_SIZE / 2
	var wall_width = 8
	var wall_color = Color(0.25, 0.15, 0.35)
	
	# Top wall
	var top = _create_wall(-half - wall_width / 2, 0, wall_width, ARENA_SIZE + wall_width * 2, wall_color)
	add_child(top)
	
	# Bottom wall
	var bottom = _create_wall(half + wall_width / 2, 0, wall_width, ARENA_SIZE + wall_width * 2, wall_color)
	add_child(bottom)
	
	# Left wall
	var left = _create_wall(0, -half - wall_width / 2, ARENA_SIZE + wall_width * 2, wall_width, wall_color)
	add_child(left)
	
	# Right wall
	var right = _create_wall(0, half + wall_width / 2, ARENA_SIZE + wall_width * 2, wall_width, wall_color)
	add_child(right)
	
	# Corner posts
	var corner_size = 16
	var corner_color = Color(0.35, 0.2, 0.45)
	for cx in [-half, half]:
		for cy in [-half, half]:
			var post = ColorRect.new()
			post.position = Vector2(cx - corner_size / 2, cy - corner_size / 2)
			post.size = Vector2(corner_size, corner_size)
			post.color = corner_color
			add_child(post)

func _create_wall(x: float, y: float, w: float, h: float, color: Color) -> StaticBody2D:
	var wall = StaticBody2D.new()
	wall.position = Vector2(x, y)
	
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	(collision.shape as RectangleShape2D).size = Vector2(w, h)
	wall.add_child(collision)
	
	# Visual
	var visual = ColorRect.new()
	visual.position = Vector2(-w / 2, -h / 2)
	visual.size = Vector2(w, h)
	visual.color = color
	wall.add_child(visual)
	
	return wall

func _create_decorations() -> void:
	# Random decorative elements (rocks, grass patches)
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("arena_decorations")
	
	for i in range(80):
		var x = rng.randf_range(-ARENA_SIZE / 2 + 50, ARENA_SIZE / 2 - 50)
		var y = rng.randf_range(-ARENA_SIZE / 2 + 50, ARENA_SIZE / 2 - 50)
		
		var deco_type = rng.randi() % 3
		match deco_type:
			0:  # Small rock
				var rock = ColorRect.new()
				var size = rng.randf_range(4, 10)
				rock.position = Vector2(x, y)
				rock.size = Vector2(size, size * rng.randf_range(0.7, 1.3))
				rock.color = Color(0.18, 0.16, 0.22)
				rock.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(rock)
			1:  # Grass patch
				var grass = ColorRect.new()
				grass.position = Vector2(x, y)
				grass.size = Vector2(6, 12)
				grass.color = Color(0.06, 0.12, 0.06)
				grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(grass)
			2:  # Dark spot
				var spot = ColorRect.new()
				var size = rng.randf_range(8, 20)
				spot.position = Vector2(x, y)
				spot.size = Vector2(size, size)
				spot.color = Color(0.06, 0.05, 0.10, 0.5)
				spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(spot)
