## achievement_manager.gd - Achievement / milestone tracking system
extends Node

const ACHIEVEMENTS = [
	{
		"id": "first_blood",
		"name": "第一滴血",
		"description": "击杀第一个敌人",
		"icon": "🩸"
	},
	{
		"id": "wave_5",
		"name": "初出茅庐",
		"description": "通过第 5 波",
		"icon": "🌊"
	},
	{
		"id": "wave_10",
		"name": "身经百战",
		"description": "通过第 10 波",
		"icon": "⚔️"
	},
	{
		"id": "wave_20",
		"name": "无双战神",
		"description": "通过第 20 波",
		"icon": "👑"
	},
	{
		"id": "score_1000",
		"name": "千金散尽",
		"description": "单局得分达到 1000",
		"icon": "💰"
	},
	{
		"id": "score_5000",
		"name": "富甲一方",
		"description": "单局得分达到 5000",
		"icon": "💎"
	},
	{
		"id": "combo_10",
		"name": "连击大师",
		"description": "达成 10 连击",
		"icon": "🔥"
	},
	{
		"id": "combo_20",
		"name": "疯狂输出",
		"description": "达成 20 连击",
		"icon": "💥"
	},
	{
		"id": "boss_slayer",
		"name": "Boss 猎手",
		"description": "击杀第一个 Boss",
		"icon": "🐉"
	},
	{
		"id": "level_10",
		"name": "等级 10",
		"description": "单局达到等级 10",
		"icon": "⭐"
	},
]

var unlocked: Dictionary = {}

signal achievement_unlocked(id: String, name: String, description: String, icon: String)

func _ready() -> void:
	_load_achievements()

func check_achievement(id: String) -> void:
	if unlocked.get(id, false):
		return

	for ach in ACHIEVEMENTS:
		if ach.id == id:
			unlocked[id] = true
			_save_achievements()
			achievement_unlocked.emit(ach.id, ach.name, ach.description, ach.icon)
			break

## Check wave-based achievements
func check_wave(wave: int) -> void:
	if wave >= 5: check_achievement("wave_5")
	if wave >= 10: check_achievement("wave_10")
	if wave >= 20: check_achievement("wave_20")

## Check score-based achievements
func check_score(score: int) -> void:
	if score >= 1000: check_achievement("score_1000")
	if score >= 5000: check_achievement("score_5000")

## Check combo achievements
func check_combo(combo: int) -> void:
	if combo >= 10: check_achievement("combo_10")
	if combo >= 20: check_achievement("combo_20")

## Check level-based achievements
func check_level(level: int) -> void:
	if level >= 10: check_achievement("level_10")

func _load_achievements() -> void:
	var file = FileAccess.open("user://achievements.json", FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json:
			unlocked = json

func _save_achievements() -> void:
	var file = FileAccess.open("user://achievements.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(unlocked, "\t"))
		file.close()
