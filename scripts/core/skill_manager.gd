## skill_manager.gd - Active skill system (spacebar / X button)
extends Node

enum SkillType { NONE, FIRE_NOVA, FROST_BLAST, LIGHTNING_STRIKE }

var current_skill: SkillType = SkillType.FIRE_NOVA
var skill_cooldown: float = 0.0
var skill_max_cooldown: float = 10.0
var skill_damage: float = 40.0
var skill_range: float = 180.0
var player_ref: Node2D = null

signal skill_used(skill_type: SkillType)
signal cooldown_updated(current: float, max: float)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if skill_cooldown > 0:
		skill_cooldown = max(0.0, skill_cooldown - delta)
		cooldown_updated.emit(skill_cooldown, skill_max_cooldown)

func try_use_skill() -> bool:
	if skill_cooldown > 0 or current_skill == SkillType.NONE:
		return false

	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return false

	player_ref = players[0] as Node2D
	if not is_instance_valid(player_ref):
		return false

	var em = get_node_or_null("/root/GameScene/EffectsManager")

	match current_skill:
		SkillType.FIRE_NOVA:
			_fire_nova()
		SkillType.FROST_BLAST:
			_frost_blast()
		SkillType.LIGHTNING_STRIKE:
			_lightning_strike()

	skill_cooldown = skill_max_cooldown
	skill_used.emit(current_skill)
	return true

func _fire_nova() -> void:
	if not player_ref or not is_instance_valid(player_ref):
		return

	var pos = player_ref.global_position
	var em = get_node_or_null("/root/GameScene/EffectsManager")

	# Visual: expanding ring
	_create_ring(pos, Color(1.0, 0.3, 0.1, 0.4), skill_range)

	# Damage all enemies in range
	var enemies = get_tree().get_nodes_in_group("enemy")
	var hit_count = 0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = pos.distance_to(enemy.global_position)
		if dist < skill_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(skill_damage, pos.direction_to(enemy.global_position))
				hit_count += 1

	# Screen shake if hits
	if hit_count > 0 and em:
		em.screen_shake(6.0, 0.15)

func _frost_blast() -> void:
	if not player_ref or not is_instance_valid(player_ref):
		return

	var pos = player_ref.global_position
	_create_ring(pos, Color(0.3, 0.6, 1.0, 0.4), skill_range)

	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = pos.distance_to(enemy.global_position)
		if dist < skill_range:
			if enemy.has_method("take_damage"):
				# Frost: less damage but slows
				enemy.take_damage(skill_damage * 0.7, pos.direction_to(enemy.global_position))
				if enemy.has_method("apply_slow"):
					enemy.apply_slow(0.5, 2.0)

func _lightning_strike() -> void:
	if not player_ref or not is_instance_valid(player_ref):
		return

	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies.shuffle()

	for i in range(min(5, enemies.size())):
		var enemy = enemies[i]
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(skill_damage * 0.6, Vector2.ZERO)
			_create_ring(enemy.global_position, Color(1.0, 1.0, 0.2, 0.5), 25)

func _create_ring(position: Vector2, color: Color, radius: float) -> void:
	var ring = ColorRect.new()
	ring.position = position - Vector2(radius, radius)
	ring.size = Vector2(radius * 2, radius * 2)
	ring.color = color
	ring.z_index = 90
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_parent().call_deferred("add_child", ring)

	var tween = get_parent().create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_callback(ring.queue_free).set_delay(0.6)
