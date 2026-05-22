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
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(440, 60)
		btn.text = "%s (Lv.%d/%d)" % [upgrade.name, UpgradeManager.upgrade_counts.get(upgrade.id, 0) + 1, upgrade.max_stack]
		btn.add_theme_font_size_override("font_size", 16)
		
		# Create colored panel behind button
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(440, 60)
		panel.add_theme_constant_override("margin_left", 8)
		panel.add_theme_constant_override("margin_right", 8)
		panel.add_theme_constant_override("margin_top", 4)
		panel.add_theme_constant_override("margin_bottom", 4)
		
		var btn_text = Label.new()
		btn_text.text = "%s\n%s" % [upgrade.name, upgrade.description]
		btn_text.add_theme_font_size_override("font_size", 14)
		btn_text.autowrap_mode = TextServer.AUTOWRAP_MODE_WORD
		panel.add_child(btn_text)
		
		panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_upgrade(i)
		)
		
		container.add_child(panel)

func _select_upgrade(index: int) -> void:
	UpgradeManager.select_upgrade(index)
	visible = false
	GameManager.change_state(GameManager.GameState.PLAYING)
