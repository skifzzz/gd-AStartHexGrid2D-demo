class_name MainScene
extends Node2D

@export var configuration_node:ConfigurationNode
@export var tilemapLayer:TileMapLayer
@export var unitSpawn:UnitSpawnNode
@export var base_spawn:BaseSpawnNode
@export var grid_debug:GridDebugNode

var _navigation_grid:AStarHexGrid2D

var _base_position:CombinedPosition

func _ready() -> void:
	_navigation_grid = AStarHexGrid2D.new(tilemapLayer)
	grid_debug.set_grid(_navigation_grid)
	Signals.reset_scene.connect(reset_scene)
	

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			if configuration_node.is_placing_units():
				var combined_position = _get_combined_position_from_mouse()
				var unit = unitSpawn.spawn(combined_position, _navigation_grid) 
				add_child(unit)
				if _base_position != null:
					unit.set_target(_base_position)
			else: if configuration_node.is_placing_base():
				var combined_position = _get_combined_position_from_mouse()

				if base_spawn.should_spawn_new():
					add_child(base_spawn.spawn(combined_position))
				else:
					base_spawn.spawn(combined_position)
				_base_position = combined_position
				
func _process(delta: float) -> void:
	pass

func _get_combined_position_from_mouse() -> CombinedPosition:
	var tile = tilemapLayer.local_to_map(tilemapLayer.get_local_mouse_position())
	var global_coords = tilemapLayer.to_global(tilemapLayer.map_to_local(tile))
	return CombinedPosition.new(tile, global_coords)

func reset_scene():
	var children = get_children()
	for child in  children:
		if child is UnitScene || child is BaseScene:
			child.queue_free()
