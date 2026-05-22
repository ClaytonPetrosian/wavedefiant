## damage_number.gd - Floating damage number effect
extends Label

var lifetime: float = 0.8
var elapsed: float = 0.0

func _ready() -> void:
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Center text
	offset_left = -30
	offset_right = 30
	offset_top = -15
	offset_bottom = 15
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(delta: float) -> void:
	elapsed += delta
	position.y -= 50.0 * delta  # Float upward
	
	if elapsed >= lifetime:
		queue_free()
		return
	
	# Fade out
	var alpha = 1.0 - (elapsed / lifetime)
	modulate.a = alpha
