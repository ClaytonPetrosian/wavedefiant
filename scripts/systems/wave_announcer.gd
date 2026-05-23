## wave_announcer.gd - Shows wave announcement text on screen
extends CanvasLayer

var label: Label = null
var current_text: String = ""

func _ready() -> void:
	label = Label.new()
	label.name = "WaveAnnounceLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 4)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(-200, -30)
	label.custom_minimum_size = Vector2(400, 60)
	label.modulate.a = 0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

	GameManager.wave_changed.connect(_on_wave_changed)

func _on_wave_changed(wave: int) -> void:
	if wave <= 0:
		return

	# Determine wave type
	var text = ""
	if wave % 5 == 0:
		text = "⚠️ BOSS WAVE %d ⚠️" % wave
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	else:
		text = "Wave %d" % wave
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	label.text = text
	label.modulate.a = 0
	label.scale = Vector2(0.5, 0.5)

	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT_BACK)

	# Hold then fade out
	await get_tree().create_timer(1.5).timeout
	var tween2 = create_tween()
	tween2.tween_property(label, "modulate:a", 0.0, 0.5)
