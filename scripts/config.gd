extends Node

enum ConfigSettings {
	DISPLAY_RESOLUTION,
}

enum DisplayPresets {
	RESOLUTION_1280_720,
	RESOLUTION_1920_1080,
	RESOLUTION_2560_1440,
	RESOLUTION_3840_2160,
	RESOLUTION_FULLSCREEN
}

var _settings_config = {}

var current_config: Dictionary :
	get:
		return _settings_config
	set(value):
		_settings_config = value

func _ready() -> void:
	pass


func set_default_config() -> void:
	_settings_config = {
		ConfigSettings.DISPLAY_RESOLUTION: DisplayPresets.RESOLUTION_1280_720
	}
