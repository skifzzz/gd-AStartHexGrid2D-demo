class_name CombinedPosition

var _tile:Vector2i
var _coords:Vector2

static func empty() -> CombinedPosition:
    return CombinedPosition.new(Vector2i(0,0), Vector2(0,0))

func _init(p_tile:Vector2i, p_coords:Vector2) -> void:
    _tile = p_tile
    _coords = p_coords

func get_tile() -> Vector2i:
    return _tile

func get_coords() -> Vector2:
    return _coords

func is_equal(p_position:CombinedPosition) -> bool:
    if p_position == null:
        return false
    else:
        return _tile == p_position.get_tile() && _coords == p_position.get_coords()

func _to_string() -> String:
    var result = ""
    if _tile == null:
        result = result + "no_tile"
    else:
        result = result + "(" + str(_tile.x) + ", " + str(_tile.y) + ")"

    result = result + " : "

    if _coords == null:
        result = result + "no_coords"
    else:
        result = result + "(" + str(_coords.x) + ", " + str(_coords.y) + ")"
    return result