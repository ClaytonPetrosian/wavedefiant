## xp_drop.gd - XP gem dropped by enemies
extends Node2D

var value: int = 5
var is_collected: bool = false
var bob_timer: float = 0.0

func _ready() -> void:
	add_to_group("xp_drop")

func _process(delta: float) -> void:
	bob_timer += delta
	if is_inside_tree():
		position.y = sin(bob_timer * 3.0) * 3.0

func _collect() -> void:
	if not is_collected:
		is_collected = true
		GameManager.add_xp(value)
		queue_free()
