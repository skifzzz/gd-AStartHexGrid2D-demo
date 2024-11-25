class_name PathDebugNode
extends Node2D

@export var enabled:bool
var color:Color
var path:PathContainer:
	set = set_path

func _draw() -> void:
	if enabled && path != null:
		var full_path = path.get_full_path()
		
		var path_buffer:Array[Vector2] = []
		for i in range(path.get_current_step(), full_path.size()):
			path_buffer.append(to_local(full_path[i].get_coords()))
		var points = PackedVector2Array(path_buffer)
		draw_polyline(points, color, 3.0)
	pass

func set_path(p_path:PathContainer):
	path = p_path
	update()

func update():
	if enabled:
		queue_redraw()
