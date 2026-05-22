## combo_manager.gd - Combo / kill streak system
## Tracks consecutive kills within a time window, grants score multipliers
extends Node

const COMBO_TIMEOUT: float = 2.0
const COMBO_MULTIPLIER_PER_STACK: float = 0.1  # +10% per stack

var combo_count: int = 0
var combo_timer: float = 0.0
var max_combo: int = 0
var combo_display_ui: Control = null

signal combo_updated(count: int, multiplier: float)
signal max_combo_updated(max: int)

func _process(delta: float) -> void:
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			_reset_combo()

func register_kill() -> void:
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	if combo_count > max_combo:
		max_combo = combo_count
		max_combo_updated.emit(max_combo)
	combo_updated.emit(combo_count, get_multiplier())

func get_multiplier() -> float:
	return 1.0 + (combo_count - 1) * COMBO_MULTIPLIER_PER_STACK

func _reset_combo() -> void:
	combo_count = 0
	combo_timer = 0.0
	combo_updated.emit(0, 1.0)

## Create combo display UI
func create_combo_display(parent: Node) -> Control:
	var panel = Control.new()
	panel.name = "ComboDisplay"
	panel.position = Vector2(600, 60)
	panel.custom_minimum_size = Vector2(200, 50)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(panel)

	var label = Label.new()
	label.name = "ComboLabel"
	label.position = Vector2(0, 0)
	label.custom_minimum_size = Vector2(200, 50)
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = ""
	panel.add_child(label)

	combo_updated.connect(func(count, _mult):
		if count > 1:
			label.text = "🔥 %d COMBO!" % count
			# Scale effect
			label.scale = Vector2(1.3, 1.3)
			var tween = panel.create_tween()
			tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT)
			# Color based on combo count
			if count >= 20:
				label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
			elif count >= 10:
				label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
			else:
				label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		else:
			label.text = ""
	)

	return panel
