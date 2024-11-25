class_name AStarHexGrid2D

const EMPTY_CELL:float = -1.0

var width:int = 0
var offset: Vector2i = Vector2i(0, 0)
var cells_map: Dictionary # int:Array[float]
var navigation: AStar2D
var _map_state_mutex: Mutex = Mutex.new()
var _tilemap:TileMapLayer
var _share_tiles:bool = true
var _stop_before_target_tile:bool = false
var _config_version:int = 0
var _config_update_semaphore:Semaphore = Semaphore.new()

func _init(p_tilemap:TileMapLayer) -> void:
	_tilemap = p_tilemap
	var all_cells = _tilemap.get_used_cells()
	_build_cell_map(all_cells)
	_config_navigation(all_cells.size())
	Signals.path_configuration_changed.connect(update_configuration)
	Signals.reset_scene.connect(clear_all_blocked_tiles)

func _build_cell_map(p_cells_list:Array[Vector2i]):
	_map_state_mutex.lock()
	print("Size:", p_cells_list.size())
	print(p_cells_list)
	
	_calculate_offset(p_cells_list)
	_create_initial_map(p_cells_list)
		
	_calculate_width()
	_append_empty_cells()
	_map_state_mutex.unlock()
	for cell_line in cells_map:
		print(cell_line, ": ", cells_map[cell_line], " size:", cells_map[cell_line].size())

func _config_navigation(p_initial_size:int):
	navigation = AStar2D.new()
	navigation.reserve_space(p_initial_size)

	for y in cells_map:
		var row = cells_map[y]
		for x in range(row.size()):
			if row[x] != EMPTY_CELL:
				var local_coords = Vector2i(x, y)
				var index = vector_to_index(local_coords)
				navigation.add_point(index, local_coords)
	
	# second iteration to add connections to prevent errors 
	# for points that not yet exist
	for y in cells_map:
		var row = cells_map[y]
		for x in range(row.size()):
			if row[x] != EMPTY_CELL:
				var local_coords = Vector2i(x, y)
				var index = vector_to_index(local_coords)
				var neighbors = _tilemap.get_surrounding_cells(local_coords - offset)
				for neighbor in neighbors:
					var neighbor_id = _tilemap.get_cell_source_id(neighbor)
					if neighbor_id != -1:
						var neighbor_index = vector_to_index(neighbor + offset)
						navigation.connect_points(index, neighbor_index)

func _calculate_offset(p_cells_list:Array[Vector2i]):
	offset.x = 0
	offset.y = 0
	for cell in p_cells_list:
		if cell.x < offset.x:
			offset.x = cell.x
		if cell.y < offset.y:
			offset.y = cell.y
	offset.x = abs(offset.x)
	offset.y = abs(offset.y)

func _create_initial_map(p_cells_list:Array[Vector2i]):
	for cell in p_cells_list:
		var with_offset = cell + offset
		
		if !cells_map.has(with_offset.y):
			cells_map[with_offset.y] = []
		
		if cells_map[with_offset.y].size() <= with_offset.x:
			var diff = with_offset.x - cells_map[with_offset.y].size()
			for _i in range(diff + 1):
				cells_map[with_offset.y].append(EMPTY_CELL)
		cells_map[with_offset.y][with_offset.x] = 1.0
	
func _calculate_width():
	width = 0
	for row in cells_map:
		if width < cells_map[row].size():
			width = cells_map[row].size()

func _append_empty_cells():
	for row in cells_map:
		if width > cells_map[row].size():
			for _i in range(cells_map[row].size(), width):
				cells_map[row].append(EMPTY_CELL)

func index_to_vector(p_index:int) -> Vector2i:
	var y = floor(p_index / width)
	var x = p_index % width
	return Vector2i(x,y)

func vector_to_index(p_vector:Vector2i) -> int:
	assert(p_vector.x >= 0, "X should be positive or zero")
	assert(p_vector.y >= 0, "Y should be positive or zero")
	return p_vector.y * width + p_vector.x

func get_path_without_offset(p_start:Vector2i, p_end:Vector2i) -> Array[Vector2i]:
	var start_index = vector_to_index(p_start + offset)
	var end_index = vector_to_index(p_end + offset)

	_map_state_mutex.lock()
	var was_target_blocked = false
	var was_start_blocked = false
	if navigation.is_point_disabled(end_index):
		navigation.set_point_disabled(end_index, false)
		was_target_blocked = true
	
	if navigation.is_point_disabled(start_index):
		navigation.set_point_disabled(start_index, false)
		was_start_blocked = true

	var result_without_offset:Array[Vector2i] = []
	var path = navigation.get_point_path(start_index, end_index)

	if was_target_blocked:
		navigation.set_point_disabled(end_index, true)
	if was_start_blocked:
		navigation.set_point_disabled(start_index, true)
	_map_state_mutex.unlock()

	for point in path:
		result_without_offset.append(Vector2i(point) - offset)

	return result_without_offset

func get_path_wrapped(p_start:Vector2i, p_end:Vector2i, p_config_version:int = -1) -> PathContainer:
	_wait_for_correct_version(p_config_version)

	var tiles = get_path_without_offset(p_start, p_end)
	var path:Array[CombinedPosition] = []
	for tile in tiles:
		path.append(CombinedPosition.new(tile, _tilemap.to_global(_tilemap.map_to_local(tile))))

	return PathContainer.new(path, _stop_before_target_tile)

func set_tile_blocked(p_tile:Vector2i, is_blocked:bool, changed_by:int):
	if !_share_tiles:
		_map_state_mutex.lock()
		navigation.set_point_disabled(vector_to_index(p_tile + offset), is_blocked)
		Signals.grid_changed.emit(changed_by)
		_map_state_mutex.unlock()

func dump_full_navigation_state() -> Dictionary:
	var all_cells =_tilemap.get_used_cells()
	var result = {}
	_map_state_mutex.lock()
	for cell in all_cells:
		var position = CombinedPosition.new(cell, (_tilemap.to_global(_tilemap.map_to_local(cell)) - Vector2(36,36)))
		var enabled = !navigation.is_point_disabled(vector_to_index(cell + offset))
		result[position] = enabled

	_map_state_mutex.unlock()
	return result

func update_configuration(p_configuration:PathConfiguration):
	_map_state_mutex.lock()
	_share_tiles = p_configuration.can_units_share_tile()
	if _share_tiles:
		clear_all_blocked_tiles()
	_stop_before_target_tile = p_configuration.should_stop_near_target()
	_config_version = p_configuration.get_version()
	_config_update_semaphore.post()
	_map_state_mutex.unlock()

func _wait_for_correct_version(p_version:int):
	if p_version == -1:
		print("DEBUG: Grid configuration version is ignored, current version: ", _config_version)
	else:
		if p_version != _config_version:
			_config_update_semaphore.wait()

func clear_all_blocked_tiles():
	_map_state_mutex.lock()
	var points:PackedInt64Array = navigation.get_point_ids()
	for point in points:
		navigation.set_point_disabled(point, false)
	Signals.grid_changed.emit(-1)
	_map_state_mutex.unlock()
