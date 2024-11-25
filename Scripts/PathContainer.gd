class_name PathContainer

const _proximity = 2.0

var _path:Array[CombinedPosition]
var _current_index:int = 0
var _current_position
var _stop_before_target = false

static func empty() -> PathContainer:
	var empty_path:Array[CombinedPosition] = []
	return PathContainer.new(empty_path)

func _init(p_path:Array[CombinedPosition], p_stop_before_target:bool = false):
	_path = p_path
	_current_index = 0
	_stop_before_target = p_stop_before_target

func get_target() -> CombinedPosition:
	assert(_path.size() > 0, "No path instantiated")
	return _path[_current_index]

func has_next() -> bool:
	return _current_index < get_path_active_size() - 1 && get_path_active_size() > 1

func is_end_reached() -> bool:
	return !has_next()

func is_no_path() -> bool:
	return get_path_active_size() <= 0 || get_path_active_size() == 1

func get_path_active_size():
	if _stop_before_target:
		return _path.size() - 1
	else:
		return _path.size()

func get_coords_to_move_to(p_position:Vector2) -> Vector2:
	var current_target = get_target().get_coords()
	if !target_reached(p_position):
		return current_target
	else: 
		if has_next():
			next()
			return get_target().get_coords()
		else:
			return current_target

func target_reached(p_position) -> bool:
	return is_no_path() || distance_to_target(p_position) <= _proximity

func distance_to_target(p_position:Vector2) -> float:
	return get_target().get_coords().distance_to(p_position)

func next():
	_current_position = _path[_current_index]
	_current_index = _current_index + 1

func get_current_position() -> CombinedPosition:
	return _current_position

func get_current_step() -> int:
	return _current_index

func get_full_path() -> Array[CombinedPosition]:
	return _path

func get_end_target() -> CombinedPosition:
	return _path[_path.size() - 1]

func _to_string() -> String:
	var result = "{"
	for step in _path:
		result = result + var_to_str(step.get_tile()) + ":" + var_to_str(step.get_coords()) + ", "
	result = result + "}"
	return result
