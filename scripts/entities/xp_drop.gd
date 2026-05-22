## xp_drop.gd - XP gem dropped by enemies
extends Node2D

var value: int = 5
var is_collected: bool = false
var bob_timer: float = 0.0

func _ready() -> void:
	add_to_group("xp_drop")
	# Create XP sprite if not already set
	if $Sprite2D and not $Sprite2D.texture:
		var size = 16
		var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		for x in range(size):
			for y in range(size):
				var dist = Vector2(x - 8, y - 8).length()
				if dist <= 7:
					var brightness = 1.0 - dist / 7.0
					img.set_pixel(x, y, Color(0.2 * brightness, 0.6 * brightness + 0.2, 1.0))
		$Sprite2D.texture = ImageTexture.create_from_image(img)
		$Sprite2D.scale = Vector2(1.2, 1.2)

func _process(delta: float) -> void:
	bob_timer += delta
	if is_inside_tree():
		position.y = sin(bob_timer * 3.0) * 3.0

func _collect() -> void:
	if not is_collected:
		is_collected = true
		GameManager.add_xp(value)
		queue_free()
