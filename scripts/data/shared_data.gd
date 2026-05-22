## shared_data.gd - Shared constants and enums used across scripts
class_name SharedData

enum EnemyType { SLIME, BAT, SKELETON, DEMON, BOSS }

const ENEMY_CONFIGS = {
	EnemyType.SLIME: {
		"hp": 15.0,
		"speed": 55.0,
		"damage": 8.0,
		"xp_value": 5,
		"score_value": 10,
		"color": Color(0.3, 0.7, 0.3),
		"size": 12
	},
	EnemyType.BAT: {
		"hp": 10.0,
		"speed": 77.0,  # 55 * 1.4
		"damage": 6.0,
		"xp_value": 4,
		"score_value": 8,
		"color": Color(0.5, 0.2, 0.6),
		"size": 10
	},
	EnemyType.SKELETON: {
		"hp": 22.5,  # 15 * 1.5
		"speed": 50.0,
		"damage": 12.0,
		"xp_value": 8,
		"score_value": 15,
		"color": Color(0.85, 0.85, 0.8),
		"size": 14
	},
	EnemyType.DEMON: {
		"hp": 37.5,  # 15 * 2.5
		"speed": 45.0,
		"damage": 12.0,  # 8 * 1.5
		"xp_value": 12,
		"score_value": 25,
		"color": Color(0.8, 0.15, 0.15),
		"size": 16
	},
	EnemyType.BOSS: {
		"hp": 150.0,  # 15 * 10
		"speed": 33.0,  # 55 * 0.6
		"damage": 16.0,  # 8 * 2
		"xp_value": 25,  # 5 * 5
		"score_value": 100,  # 10 * 10
		"color": Color(0.6, 0.05, 0.05),
		"size": 22
	}
}

const UPGRADE_DEFS = [
	{
		"id": "hp_boost",
		"name": "生命强化",
		"description": "最大生命值 +25",
		"color": Color(0.9, 0.2, 0.2),
		"max_stack": 5
	},
	{
		"id": "speed_boost",
		"name": "疾步",
		"description": "移动速度 +15%",
		"color": Color(0.2, 0.8, 0.9),
		"max_stack": 4
	},
	{
		"id": "damage_boost",
		"name": "力量",
		"description": "攻击力 +20%",
		"color": Color(1.0, 0.6, 0.1),
		"max_stack": 5
	},
	{
		"id": "attack_speed",
		"name": "急速",
		"description": "攻击速度 +15%",
		"color": Color(1.0, 0.9, 0.2),
		"max_stack": 5
	},
	{
		"id": "attack_range",
		"name": "射程",
		"description": "攻击范围 +20%",
		"color": Color(0.6, 0.5, 1.0),
		"max_stack": 4
	},
	{
		"id": "multi_shot",
		"name": "多重射击",
		"description": "同时发射 +1 个弹道",
		"color": Color(0.3, 1.0, 0.3),
		"max_stack": 3
	},
]
