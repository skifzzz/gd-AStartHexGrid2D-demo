class_name ConfigurationNode
extends Node2D

var _can_share_tile:bool = false


@onready var units_toggle = get_node("VBoxContainer/Panel/UnitButton")
@onready var base_toggle = get_node("VBoxContainer/Panel/BaseButton")

@onready var can_share_tile_toggle = get_node("VBoxContainer/Panel/CanShareTileButton")
@onready var stop_near_target_toggle = get_node("VBoxContainer/Panel/StopNearTargetButton")


@onready var _placing_units = units_toggle.button_pressed
@onready var _placing_base = base_toggle.button_pressed
@onready var _path_config = PathConfiguration.new(can_share_tile_toggle.button_pressed, stop_near_target_toggle.button_pressed, _config_version)

var _config_version:int = 0
var _config_mutex:Mutex = Mutex.new()

func _on_base_button_toggled(toggled_on:bool) -> void:
	_placing_base = toggled_on
	_placing_units = !toggled_on

func _on_unit_button_toggled(toggled_on:bool) -> void:
	_placing_units = toggled_on
	_placing_base = !toggled_on

func _on_can_share_tile_button_toggled(toggled_on:bool) -> void:
	_path_config = PathConfiguration.new(toggled_on, _path_config.should_stop_near_target(), _increment_and_get_config_version())
	Signals.path_configuration_changed.emit(_path_config)

func _on_stop_near_target_button_toggled(toggled_on:bool) -> void:
	_path_config = PathConfiguration.new(_path_config.can_units_share_tile(), toggled_on, _increment_and_get_config_version())
	Signals.path_configuration_changed.emit(_path_config)

func is_placing_units() -> bool:
	return _placing_units

func is_placing_base() -> bool:
	return _placing_base
	
func get_path_config() -> PathConfiguration:
	return _path_config

func _on_reset_button_pressed() -> void:
	Signals.reset_scene.emit()

func _increment_and_get_config_version() -> int:
	var version = 0
	_config_mutex.lock()
	_config_version = _config_version + 1
	version = _config_version
	_config_mutex.unlock()
	return version
