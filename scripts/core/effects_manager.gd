## effects_manager.gd - Central effects manager (damage numbers, particles, etc.)
extends Node2D

## Show floating damage number at position
func show_damage_number(position: Vector2, amount: float, color: Color = Color.WHITE, is_crit: bool = false) -> void:
	var label = Label.new()
	label.text = str(int(amount))
	if is_crit:
		label.text += "!"
	label.position = position + Vector2(randf_range(-10, 10), -10)
	label.z_index = 100
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 22 if is_crit else 16)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.offset_left = -30
	label.offset_right = 30
	label.offset_top = -12
	label.offset_bottom = 12
	add_child(label)

	# Float up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 0.7).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free).set_delay(0.75)

## Spawn death burst particles
func spawn_death_burst(position: Vector2, color: Color = Color(1.0, 0.85, 0.2)) -> void:
	for i in range(8):
		var dot = ColorRect.new()
		dot.size = Vector2(4, 4)
		dot.position = position
		dot.color = color
		dot.z_index = 99
		add_child(dot)

		var angle = (TAU / 8.0) * i
		var target = position + Vector2(cos(angle), sin(angle)) * randf_range(30.0, 60.0)
		var t = create_tween()
		t.set_parallel(true)
		t.tween_property(dot, "position", target, 0.35).set_ease(Tween.EASE_OUT)
		t.tween_property(dot, "modulate:a", 0.0, 0.35)
		t.tween_callback(dot.queue_free).set_delay(0.4)
