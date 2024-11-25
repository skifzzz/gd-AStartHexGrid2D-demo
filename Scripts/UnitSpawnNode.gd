class_name UnitSpawnNode
extends Node2D

const UNIT_SCENE = preload("res://unit.tscn")

func spawn(p_position: CombinedPosition, p_navigation_grid:AStarHexGrid2D) -> UnitScene:
	var unit = UNIT_SCENE.instantiate() as UnitScene
	unit.position = p_position.get_coords()
	unit.set_current_position(p_position)
	unit.set_navigation_grid(p_navigation_grid)
	return unit 
