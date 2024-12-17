extends GutTest


const BOTTOM_LEFT_TILE_INDEX = Vector2(-2, 0)
const BOTTOM_TILE_INDEX = Vector2(-1, 0)
const BOTTOM_RIGHT_TILE_INDEX = Vector2(0, 0)

const CENTER_TILE_INDEX = Vector2(-1, -1)

const TOP_LEFT_TILE_INDEX = Vector2(-2, -1)
const TOP_TILE_INDEX = Vector2(-1, -2)
const TOP_RIGHT_TILE_INDEX = Vector2(0, -1)

const NO_UNIT_ID = -1

var under_test:AStarHexGrid2D
# Hardcoded for now
var TOP_TILE_COMBINED_POSITION = CombinedPosition.new(TOP_TILE_INDEX, Vector2(-54, -108))

func before_all():   
    var tile_set:TileSet = load("res://resources/main_tile_set.tres")
    var tile_map = TileMapLayer.new()
    tile_map.tile_set = tile_set
    tile_map.set_cell(BOTTOM_RIGHT_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(TOP_RIGHT_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(TOP_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(TOP_LEFT_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(BOTTOM_LEFT_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(BOTTOM_TILE_INDEX, 0, Vector2(0,0))
    tile_map.set_cell(CENTER_TILE_INDEX, 0, Vector2(0,0))
    under_test = AStarHexGrid2D.new(tile_map)

func test_initialization_was_correct():
    assert_eq(under_test.dump_full_navigation_state().size(), 7, "7 tiles should be initialized")

func test_there_is_simple_path():
    var path = under_test.get_path_wrapped(TOP_TILE_INDEX, BOTTOM_TILE_INDEX)
    assert_true(path != null)
    assert_false(path.is_no_path(), "Should have path")
    assert_eq(path.get_path_active_size(), 3, "Path should be 3 tiles long")

func test_can_block_tile():
    under_test.set_tile_blocked(TOP_TILE_INDEX, true, NO_UNIT_ID)
    var navigation_state = under_test.dump_full_navigation_state()
    assert_false(_find_value_in_dump_for_tile(navigation_state, TOP_TILE_INDEX))
    under_test.set_tile_blocked(TOP_TILE_INDEX, false, NO_UNIT_ID)

func test_can_unblock_tile():
    under_test.set_tile_blocked(TOP_TILE_INDEX, true, NO_UNIT_ID)
    var navigation_state = under_test.dump_full_navigation_state()
    assert_false(_find_value_in_dump_for_tile(navigation_state, TOP_TILE_INDEX))

    under_test.set_tile_blocked(TOP_TILE_INDEX, false, NO_UNIT_ID)
    navigation_state = under_test.dump_full_navigation_state()
    assert_true(_find_value_in_dump_for_tile(navigation_state, TOP_TILE_INDEX))

func test_path_can_blocked():
    under_test.set_tile_blocked(BOTTOM_LEFT_TILE_INDEX, true, NO_UNIT_ID)
    under_test.set_tile_blocked(CENTER_TILE_INDEX, true, NO_UNIT_ID)
    under_test.set_tile_blocked(BOTTOM_RIGHT_TILE_INDEX, true, NO_UNIT_ID)
    var path = under_test.get_path_wrapped(BOTTOM_TILE_INDEX, TOP_TILE_INDEX)
    assert_eq(path.get_path_active_size(), 0)

    under_test.set_tile_blocked(BOTTOM_LEFT_TILE_INDEX, false, NO_UNIT_ID)
    under_test.set_tile_blocked(CENTER_TILE_INDEX, false, NO_UNIT_ID)
    under_test.set_tile_blocked(BOTTOM_RIGHT_TILE_INDEX, false, NO_UNIT_ID)

func _find_value_in_dump_for_tile(p_dump:Dictionary, p_tile:Vector2) -> bool:
    var found = false
    var value = false
    for key in p_dump:
        if (key as CombinedPosition).get_tile() == Vector2i(p_tile):
            value = p_dump.get(key)
            found = true
    
    assert(found, "Should found value")
    return value


    
