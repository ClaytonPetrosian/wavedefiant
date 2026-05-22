## upgrade_manager.gd - Manages level-up upgrade selection
## Offers random upgrades, applies stat boosts
extends Node

const UPGRADES = [
	{
		"id": "hp_boost",
		"name": "生命强化",
		"description": "最大生命值 +25",
		"icon_color": Color(0.9, 0.2, 0.2),
		"max_stack": 5,
		"apply": func(player): 
			player.max_hp += 25
			player.hp = min(player.hp + 25, player.max_hp)
	},
	{
		"id": "speed_boost",
		"name": "疾步",
		"description": "移动速度 +15%",
		"icon_color": Color(0.2, 0.8, 0.9),
		"max_stack": 4,
		"apply": func(player):
			player.speed *= 1.15
	},
	{
		"id": "damage_boost",
		"name": "力量",
		"description": "攻击力 +20%",
		"icon_color": Color(1.0, 0.6, 0.1),
		"max_stack": 5,
		"apply": func(player):
			player.attack_damage *= 1.2
	},
	{
		"id": "attack_speed",
		"name": "急速",
		"description": "攻击速度 +15%",
		"icon_color": Color(1.0, 0.9, 0.2),
		"max_stack": 5,
		"apply": func(player):
			player.attack_interval *= 0.85
	},
	{
		"id": "attack_range",
		"name": "射程",
		"description": "攻击范围 +20%",
		"icon_color": Color(0.6, 0.5, 1.0),
		"max_stack": 4,
		"apply": func(player):
			player.attack_range *= 1.2
	},
	{
		"id": "multi_shot",
		"name": "多重射击",
		"description": "同时发射 +1 个弹道",
		"icon_color": Color(0.3, 1.0, 0.3),
		"max_stack": 3,
		"apply": func(player):
			player.projectile_count += 1
	},
	{
		"id": "xp_magnet",
		"name": "经验磁吸",
		"description": "XP 拾取范围 +30%",
		"icon_color": Color(0.3, 0.6, 1.0),
		"max_stack": 3,
		"apply": func(player):
			player.xp_magnet_range *= 1.3
	},
	{
		"id": "regen",
		"name": "生命恢复",
		"description": "每秒恢复 2% 最大生命值",
		"icon_color": Color(0.2, 0.9, 0.4),
		"max_stack": 3,
		"apply": func(player):
			pass  # Handled in game_scene
	},
]

var upgrade_counts: Dictionary = {}
var offered_upgrades: Array = []

signal upgrades_offered(upgrades: Array)
signal upgrade_selected(upgrade: Dictionary)

func _ready() -> void:
	for u in UPGRADES:
		upgrade_counts[u.id] = 0

func generate_offers(count: int = 3) -> Array:
	offered_upgrades.clear()
	
	var available = UPGRADES.filter(func(u): 
		return upgrade_counts.get(u.id, 0) < u.max_stack
	)
	
	# Shuffle and pick
	available.shuffle()
	
	for i in range(min(count, available.size())):
		offered_upgrades.append(available[i])
	
	upgrades_offered.emit(offered_upgrades.duplicate())
	return offered_upgrades.duplicate()

func select_upgrade(upgrade_index: int) -> void:
	if upgrade_index < 0 or upgrade_index >= offered_upgrades.size():
		return
	
	var upgrade = offered_upgrades[upgrade_index]
	upgrade_counts[upgrade.id] = upgrade_counts.get(upgrade.id, 0) + 1
	
	# Find player and apply
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		upgrade.apply.call(player)
	
	upgrade_selected.emit(upgrade)
	offered_upgrades.clear()

func get_upgrade_display(upgrade: Dictionary) -> Dictionary:
	var count = upgrade_counts.get(upgrade.id, 0)
	return {
		"name": upgrade.name,
		"description": upgrade.description,
		"icon_color": upgrade.icon_color,
		"level": count + 1,
		"max_level": upgrade.max_stack
	}
