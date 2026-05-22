## effects_manager.gd - Central effects manager (damage numbers, particles)
extends Node2D

func spawn_damage_number(pos: Vector2, amount: float, color: Color = Color.WHITE, is_crit: bool = false) -> void:
	var label = Label.new()
	label.text = str(int(amount))
	if is_crit:
		label.text += "!"
	label.position = pos + Vector2(randf_range(-10, 10), -10)
	label.z_index = 100
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 22 if is_crit else 16)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 0.7).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free).set_delay(0.75)

func spawn_kill_effect(pos: Vector2) -> void:
	for i in range(10):
		var dot = ColorRect.new()
		dot.size = Vector2(4, 4)
		dot.position = pos
		dot.color = Color(1.0, 0.85, 0.2)
		dot.z_index = 99
		add_child(dot)
		
		var angle = (TAU / 10.0) * i
		var dist = randf_range(25.0, 55.0)
		var target = pos + Vector2(cos(angle), sin(angle)) * dist
		
		var t = create_tween()
		t.set_parallel(true)
		t.tween_property(dot, "position", target, 0.35).set_ease(Tween.EASE_OUT)
		tween.tween_property(dot, "modulate:a", 0.0, 0.35)
		t.tween_callback(dot.queue_free).set_delay(0.4)
