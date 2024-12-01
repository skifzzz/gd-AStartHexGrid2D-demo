class_name UnitScene
extends Node2D

const VELOCITY = 100.0

@export var character:CharacterBody2D
@export var anchor:Marker2D
@export var path_debug:PathDebugNode

var _color:Color
var _path:PathContainer = PathContainer.empty()
var _current_position:CombinedPosition
var _navigation_grid

func _init() -> void:
	_color = Color(randf(),randf(),randf(),1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = _color
	path_debug.color = _color
	Signals.target_changed.connect(_on_target_changed)
	Signals.path_configuration_changed.connect(_on_path_configuration_update)
	Signals.grid_changed.connect(_on_navigation_refresh)

func _physics_process(delta: float) -> void:
	if can_move(anchor.global_position):

		if should_update_position_to(_path.get_target()):
			set_current_position(_path.get_target())
			path_debug.update()

		var target_coords = _path.get_coords_to_move_to(anchor.global_position)
		# Safe velocity to slowdown when reaching target
		# character.velocity = character.global_position.direction_to(target_coords) * (character.global_position.distance_to(target_coords) / VELOCITY) * VELOCITY
		character.velocity = anchor.global_position.direction_to(target_coords) * VELOCITY * delta * 50
		character.move_and_slide()
	else:
		if _current_position == null && _path.get_current_position() != null:
			_current_position = _path.get_current_position()

		if _current_position.get_coords().distance_to(anchor.global_position) < 3:
			character.velocity = Vector2(0,0)
		else:
			character.velocity = anchor.global_position.direction_to(_current_position.get_coords()) * VELOCITY * delta * 50
			character.move_and_slide()

func can_move(p_position:Vector2) -> bool:
	return !_path.target_reached(p_position) || _path.has_next()

func set_target(p_position:CombinedPosition):
	_on_target_changed(p_position)

func _on_target_changed(p_position:CombinedPosition):
	if _path == null || _path.get_current_position() == null:
		_path = _navigation_grid.get_path_wrapped(_current_position.get_tile(), p_position.get_tile())
	else:
		_path = _navigation_grid.get_path_wrapped(_path.get_current_position().get_tile(), p_position.get_tile())

	path_debug.set_path(_path)
	path_debug.update()


func should_update_position_to(p_position:CombinedPosition) -> bool:
	return _current_position == null || _current_position.get_coords().distance_to(anchor.global_position) > p_position.get_coords().distance_to(anchor.global_position)

func set_current_position(p_position:CombinedPosition):
	if _navigation_grid != null:
		if _current_position != null:
			_navigation_grid.set_tile_blocked(_current_position.get_tile(), false, get_instance_id())
		if p_position != null:
			_navigation_grid.set_tile_blocked(p_position.get_tile(), true, get_instance_id())
	_current_position = p_position

func set_navigation_grid(p_grid:AStarHexGrid2D):
	_navigation_grid = p_grid
	if _current_position != null:
			_navigation_grid.set_tile_blocked(_current_position.get_tile(), true, get_instance_id())

func _on_path_configuration_update(p_configuration:PathConfiguration):
	if !_path.is_no_path():
		_path = _navigation_grid.get_path_wrapped(_current_position.get_tile(), _path.get_end_target().get_tile(), p_configuration.get_version())
		# CAN BREAK ANYTHING
		if should_update_position_to(_path.get_target()):
			set_current_position(_path.get_target())
		if !_path.is_end_reached() && _path.get_target().get_tile() == _current_position.get_tile():
			_path.next()
			if should_update_position_to(_path.get_target()):
				set_current_position(_path.get_target())

		path_debug.set_path(_path)
		path_debug.update()

func _on_navigation_refresh(p_changed_by:int):
	if self.get_instance_id() != p_changed_by:
		refresh_path()


func refresh_path():
	if !_path.is_no_path():
		_path = _navigation_grid.get_path_wrapped(_current_position.get_tile(), _path.get_end_target().get_tile())
		# CAN BREAK ANYTHING
		if !_path.is_end_reached() && _path.get_target().get_tile() == _current_position.get_tile():
			_path.next()
		path_debug.set_path(_path)
		path_debug.update()