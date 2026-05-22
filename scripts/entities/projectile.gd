## projectile.gd - Homing projectile that tracks target
extends Area2D

var target: Node2D = null
var damage: float = 10.0
var crit_chance: float = 0.05
var crit_multiplier: float = 2.0
var speed: float = 350.0
var lifetime: float = 3.0
var elapsed: float = 0.0

func _ready() -> void:
	z_index = 50

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > lifetime:
		queue_free()
		return

	if not is_instance_valid(target):
		# Find new target or die
		var enemies = get_tree().get_nodes_in_group("enemy")
		var nearest_dist: float = 300.0
		target = null
		for e in enemies:
			if not is_instance_valid(e):
				continue
			var dist = global_position.distance_to(e.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				target = e

	if target and is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		position += direction * speed * delta
		# Rotate to face direction
		rotation = direction.angle()

	# Check collision with enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) < 20:
			_hit_enemy(enemy)
			queue_free()
			return

func _hit_enemy(enemy: Node) -> void:
	var is_crit = randf() < crit_chance
	var final_damage = damage * crit_multiplier if is_crit else damage

	if enemy.has_method("take_damage"):
		var knockback_dir = global_position.direction_to(enemy.global_position) if target else Vector2.RIGHT
		enemy.take_damage(final_damage, knockback_dir)

	# Show damage number
	var em = get_node_or_null("/root/GameScene/EffectsManager")
	if em:
		var color = Color(1.0, 0.4, 0.2) if is_crit else Color(1.0, 1.0, 1.0)
		em.show_damage_number(enemy.global_position, final_damage, color, is_crit)
