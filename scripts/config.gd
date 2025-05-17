extends Node

enum ConfigSettings {
	DISPLAY_RESOLUTION,
	CONTROL_KEY_DOWN,
	CONTROL_KEY_LEFT,
	CONTROL_KEY_RIGHT,
	CONTROL_KEY_JUMP,
	CONTROL_KEY_DASH,
	CONTROL_PAD_DOWN,
	CONTROL_PAD_LEFT,
	CONTROL_PAD_RIGHT,
	CONTROL_PAD_JUMP,
	CONTROL_PAD_DASH,
}

enum DisplayPresets {
	RESOLUTION_1280_720,
	RESOLUTION_1920_1080,
	RESOLUTION_2560_1440,
	RESOLUTION_3840_2160,
	RESOLUTION_FULLSCREEN
}

# Dictionary containing the game's settings
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
		ConfigSettings.DISPLAY_RESOLUTION: DisplayPresets.RESOLUTION_1280_720,
		ConfigSettings.CONTROL_KEY_JUMP: ""
	}
