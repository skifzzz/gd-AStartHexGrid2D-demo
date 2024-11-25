class_name BaseSpawnNode
extends Node2D

const BASE_SCENE = preload("res://base.tscn")

var _base:BaseScene

func spawn(p_position:CombinedPosition) -> BaseScene:
	if should_spawn_new():
		var base = BASE_SCENE.instantiate()
		base.position = p_position.get_coords()
		_base = base
	else:
		_base.position = p_position.get_coords()

	Signals.target_changed.emit(p_position)

	return _base

func should_spawn_new() -> bool:
	return _base == null
