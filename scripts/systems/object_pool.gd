## object_pool.gd - Object pool for projectiles, enemies, effects
## Reduces garbage collection pressure by reusing objects
extends Node

var _pools: Dictionary = {}

## Get or create a pooled object
func get_pooled(scene_path: String, parent: Node) -> Node:
	if not _pools.has(scene_path):
		_pools[scene_path] = []

	var pool = _pools[scene_path] as Array

	if pool.size() > 0:
		var obj = pool.pop_back() as Node
		if is_instance_valid(obj) and obj.get_parent() == null:
			parent.add_child(obj)
			obj.set_process(true)
			obj.set_physics_process(true)
			obj.visible = true
			return obj
		else:
			# Object was freed elsewhere, discard and create new
			if is_instance_valid(obj):
				obj.queue_free()

	# Create new
	var scene = load(scene_path)
	if scene:
		var obj = scene.instantiate()
		parent.add_child(obj)
		return obj

	return null

## Return object to pool instead of freeing
func return_to_pool(obj: Node) -> void:
	var scene_path = obj.scene_file_path
	if not scene_path:
		obj.queue_free()
		return

	if not _pools.has(scene_path):
		_pools[scene_path] = []

	if obj.get_parent():
		obj.get_parent().remove_child(obj)

	obj.set_process(false)
	obj.set_physics_process(false)
	obj.visible = false

	_pools[scene_path].append(obj)

## Clear all pools
func clear_all() -> void:
	for pool in _pools.values():
		for obj in pool:
			if is_instance_valid(obj):
				obj.queue_free()
		pool.clear()
	_pools.clear()

## Get pool stats
func get_pool_stats() -> Dictionary:
	var stats = {}
	for path in _pools:
		stats[path] = _pools[path].size()
	return stats
