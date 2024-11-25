class_name PathConfiguration

var _units_can_share_tile:bool:
    get = can_units_share_tile

var _stop_near_target:
    get = should_stop_near_target

var _version:int:
    get = get_version

func _init(p_can_share_tile:bool, p_stop_near_target:bool, p_version: int) -> void:
    _units_can_share_tile = p_can_share_tile
    _stop_near_target = p_stop_near_target
    _version = p_version

func can_units_share_tile() -> bool:
    return _units_can_share_tile

func should_stop_near_target() -> bool:
    return _stop_near_target

func get_version() -> int:
    return _version
