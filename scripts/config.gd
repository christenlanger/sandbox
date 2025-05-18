extends Node

const USER_PATH := "user://config.dat"

enum ConfigSettings {
	DISPLAY_MODE,
	CONTROLS,
	CONTROLS_KEY,
	CONTROLS_PAD,
	CONTROL_UP,
	CONTROL_DOWN,
	CONTROL_LEFT,
	CONTROL_RIGHT,
	CONTROL_JUMP,
	CONTROL_DASH,
}

# Dictionary containing the game's settings
var _settings_config = {}

var current_config: Dictionary :
	get:
		return _settings_config
	set(value):
		_settings_config = value


func _ready() -> void:
	set_default_config()
	read_inputmap_to_config()
	load_config()
	apply_config_settings()


func set_default_config() -> void:
	InputMap.load_from_project_settings()
	
	_settings_config = {
		ConfigSettings.DISPLAY_MODE: DisplayServer.WINDOW_MODE_WINDOWED
	}


func apply_default_config() -> void:
	set_default_config()
	read_inputmap_to_config()
	apply_config_settings()


func apply_config_settings() -> void:
	DisplayServer.window_set_mode(_settings_config[ConfigSettings.DISPLAY_MODE])
	apply_inputmap_from_config(_settings_config[ConfigSettings.CONTROLS])


# Return the first event from an action by type (0: key; 1: gamepad)
func _get_action_event_by_type(action: String, type: int) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if type and event is InputEventJoypadButton:
			return event
		elif not type and event is InputEventKey:
			return event
	
	return null


# Apply config changes
func apply_config_changes(config: Dictionary) -> void:
	_settings_config = config.duplicate(true)
	read_inputmap_to_config()
	save_config()


# Read the input map and create a variable readable by our config structure
func read_inputmap_to_config() -> void:
	var controls = {
		ConfigSettings.CONTROLS_KEY: {
			ConfigSettings.CONTROL_UP: _get_action_event_by_type(Global.action_list[Global.ActionList.UP], 0),
			ConfigSettings.CONTROL_DOWN: _get_action_event_by_type(Global.action_list[Global.ActionList.DOWN], 0),
			ConfigSettings.CONTROL_LEFT: _get_action_event_by_type(Global.action_list[Global.ActionList.LEFT], 0),
			ConfigSettings.CONTROL_RIGHT: _get_action_event_by_type(Global.action_list[Global.ActionList.RIGHT], 0),
			ConfigSettings.CONTROL_JUMP: _get_action_event_by_type(Global.action_list[Global.ActionList.JUMP], 0),
			ConfigSettings.CONTROL_DASH: _get_action_event_by_type(Global.action_list[Global.ActionList.DASH], 0),
		},
		ConfigSettings.CONTROLS_PAD: {
			ConfigSettings.CONTROL_UP: _get_action_event_by_type(Global.action_list[Global.ActionList.UP], 1),
			ConfigSettings.CONTROL_DOWN: _get_action_event_by_type(Global.action_list[Global.ActionList.DOWN], 1),
			ConfigSettings.CONTROL_LEFT: _get_action_event_by_type(Global.action_list[Global.ActionList.LEFT], 1),
			ConfigSettings.CONTROL_RIGHT: _get_action_event_by_type(Global.action_list[Global.ActionList.RIGHT], 1),
			ConfigSettings.CONTROL_JUMP: _get_action_event_by_type(Global.action_list[Global.ActionList.JUMP], 1),
			ConfigSettings.CONTROL_DASH: _get_action_event_by_type(Global.action_list[Global.ActionList.DASH], 1),
		}
	}
	
	_settings_config[ConfigSettings.CONTROLS] = controls.duplicate(true)
	

# Apply input map from saved config
func apply_inputmap_from_config(controls: Dictionary) -> void:
	var action_list = {
		Global.action_list[Global.ActionList.JUMP]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_JUMP],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_JUMP]
		],
		Global.action_list[Global.ActionList.DASH]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_DASH],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_DASH]
		],
		Global.action_list[Global.ActionList.UP]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_UP],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_UP]
		],
		Global.action_list[Global.ActionList.DOWN]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_DOWN],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_DOWN]
		],
		Global.action_list[Global.ActionList.LEFT]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_LEFT],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_LEFT]
		],
		Global.action_list[Global.ActionList.RIGHT]: [
			controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_RIGHT],
			controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_RIGHT]
		],
	}
	
	for action in action_list.keys():
		InputMap.action_erase_events(action)
		for event in action_list[action]:
			InputMap.action_add_event(action, event)


func load_config() -> void:
	if not FileAccess.file_exists(USER_PATH):
		save_config()
	
	var file := FileAccess.open(USER_PATH, FileAccess.READ)
	var temp_config: Dictionary = file.get_var(true)
	file.close()
	
	# Manually assign all config values
	var incoming_changes = {
		ConfigSettings.DISPLAY_MODE: temp_config[ConfigSettings.DISPLAY_MODE],
		ConfigSettings.CONTROLS: {
			ConfigSettings.CONTROLS_KEY: {
				ConfigSettings.CONTROL_UP: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_UP],
				ConfigSettings.CONTROL_DOWN: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_DOWN],
				ConfigSettings.CONTROL_LEFT: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_LEFT],
				ConfigSettings.CONTROL_RIGHT: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_RIGHT],
				ConfigSettings.CONTROL_JUMP: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_JUMP],
				ConfigSettings.CONTROL_DASH: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_DASH],
			},
			ConfigSettings.CONTROLS_PAD: {
				ConfigSettings.CONTROL_UP: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_UP],
				ConfigSettings.CONTROL_DOWN: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_DOWN],
				ConfigSettings.CONTROL_LEFT: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_LEFT],
				ConfigSettings.CONTROL_RIGHT: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_RIGHT],
				ConfigSettings.CONTROL_JUMP: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_JUMP],
				ConfigSettings.CONTROL_DASH: temp_config[ConfigSettings.CONTROLS][ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_DASH],
			}
		}
	}
	
	_settings_config = incoming_changes.duplicate(true)


func save_config() -> void:
	var file := FileAccess.open(USER_PATH, FileAccess.WRITE)
	file.store_var(_settings_config, true)
	file.close()
