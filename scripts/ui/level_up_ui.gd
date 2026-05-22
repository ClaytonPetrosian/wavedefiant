## level_up_ui.gd - Level up upgrade selection UI
extends Control

func _show_upgrades() -> void:
	var container = get_node_or_null("UpgradeContainer")
	if not container:
		return

	# Clear old buttons
	for child in container.get_children():
		child.queue_free()

	# Generate offers
	var upgrades = UpgradeManager.generate_offers(3)

	for i in range(upgrades.size()):
		var upgrade = upgrades[i]
		var btn_text = upgrade.name
		var btn_desc = upgrade.description
		var current_level = UpgradeManager.upgrade_counts.get(upgrade.id, 0)
		var max_level = upgrade.max_stack
		var level_str = "(Lv.%d/%d)" % [current_level + 1, max_level]

		# Button panel
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(440, 55)
		panel.add_theme_constant_override("margin_left", 10)
		panel.add_theme_constant_override("margin_right", 10)
		panel.add_theme_constant_override("margin_top", 6)
		panel.add_theme_constant_override("margin_bottom", 6)

		var vbox = VBoxContainer.new()
		panel.add_child(vbox)

		var name_label = Label.new()
		name_label.text = "%s  %s" % [btn_text, level_str]
		name_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(name_label)

		var desc_label = Label.new()
		desc_label.text = btn_desc
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.modulate = Color(0.7, 0.7, 0.8)
		vbox.add_child(desc_label)

		panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_upgrade(i)
		)

		container.add_child(panel)

func _select_upgrade(index: int) -> void:
	UpgradeManager.select_upgrade(index)
	visible = false
	GameManager.change_state(GameManager.GameState.PLAYING)
