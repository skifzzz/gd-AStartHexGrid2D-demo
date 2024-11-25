class_name GridDebugNode
extends Node2D

@export var enabled:bool:
	set = set_enabled
		
@export var open_tile_texture:Texture2D
@export var closed_tile_texture:Texture2D

var _navigation_grid:AStarHexGrid2D:
	set = set_grid

func _ready():
	Signals.grid_changed.connect(_on_redraw)	

func set_enabled(p_enabled:bool):
	enabled = p_enabled
	if enabled:
		queue_redraw()

func set_grid(p_grid:AStarHexGrid2D):
	_navigation_grid = p_grid
	queue_redraw()

func _draw() -> void:
	if enabled && _navigation_grid != null:
		var navigation_state = _navigation_grid.dump_full_navigation_state()
		for key in navigation_state:
			var texture_to_draw:Texture2D
			if navigation_state[key]:
				texture_to_draw = open_tile_texture
			else:
				texture_to_draw = closed_tile_texture
			draw_texture(texture_to_draw, key.get_coords())

func _on_redraw(_p_changed_by:int):
	queue_redraw()