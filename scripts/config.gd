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
	CONTROL_RESTART,
}

# Dictionary containing the game's settings
var _settings_config: Dictionary = {}

# Dictionary for containing the game's default controls
var default_settings: Dictionary = {}
var default_controls: Dictionary = {}


var current_config: Dictionary :
	get:
		return _settings_config
	set(value):
		_settings_config = value


func _ready() -> void:
	get_default_config()
	read_inputmap_to_config()

	# Store default control scheme in this variable
	default_settings = _settings_config.duplicate(true)
	default_controls = default_settings[ConfigSettings.CONTROLS]

	load_config()
	apply_config_settings()


# Get default settings value to config
func get_default_config() -> void:
	InputMap.load_from_project_settings()
	
	_settings_config = {
		ConfigSettings.DISPLAY_MODE: DisplayServer.WINDOW_MODE_WINDOWED
	}


# Apply the default settings
func apply_default_config() -> void:
	get_default_config()
	read_inputmap_to_config()
	apply_config_settings()


# Apply the currently stored config settings
func apply_config_settings() -> void:
	DisplayServer.window_set_mode(_settings_config[ConfigSettings.DISPLAY_MODE])
	apply_inputmap_from_config(_settings_config[ConfigSettings.CONTROLS])


# Return the first event from an action by type (0: key; 1: gamepad)
func _get_action_event_by_type(action: String, type: int) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if type and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			return event
		elif not type and event is InputEventKey:
			return event
	
	return null


# Get incoming changes, apply, and then save them to storage
# TODO: Validate formatting of the variable to make sure it's can be
# 		read by our functions
func accept_config_changes(config: Dictionary) -> void:
	_settings_config = config.duplicate(true)
	apply_config_settings()
	save_config()


# Read the input map and create a variable readable by our config structure
func read_inputmap_to_config() -> void:
	var controls = {
		ConfigSettings.CONTROLS_KEY: {
			ConfigSettings.CONTROL_UP: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.UP], 0),
			ConfigSettings.CONTROL_DOWN: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.DOWN], 0),
			ConfigSettings.CONTROL_LEFT: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.LEFT], 0),
			ConfigSettings.CONTROL_RIGHT: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.RIGHT], 0),
			ConfigSettings.CONTROL_JUMP: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.JUMP], 0),
			ConfigSettings.CONTROL_DASH: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.DASH], 0),
			ConfigSettings.CONTROL_RESTART: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.RESTART], 0),
		},
		ConfigSettings.CONTROLS_PAD: {
			ConfigSettings.CONTROL_UP: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.UP], 1),
			ConfigSettings.CONTROL_DOWN: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.DOWN], 1),
			ConfigSettings.CONTROL_LEFT: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.LEFT], 1),
			ConfigSettings.CONTROL_RIGHT: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.RIGHT], 1),
			ConfigSettings.CONTROL_JUMP: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.JUMP], 1),
			ConfigSettings.CONTROL_DASH: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.DASH], 1),
			ConfigSettings.CONTROL_RESTART: _get_action_event_by_type(Global.ACTION_LIST[Global.ActionList.RESTART], 1),
		}
	}
	
	_settings_config[ConfigSettings.CONTROLS] = controls
	

# Apply input map from saved config
func apply_inputmap_from_config(controls: Dictionary) -> void:
	var key_controls = controls[ConfigSettings.CONTROLS_KEY]
	var pad_controls = controls[ConfigSettings.CONTROLS_PAD]
	var action_list = {
		Global.ACTION_LIST[Global.ActionList.JUMP]: [
			key_controls[ConfigSettings.CONTROL_JUMP],
			pad_controls[ConfigSettings.CONTROL_JUMP]
		],
		Global.ACTION_LIST[Global.ActionList.DASH]: [
			key_controls[ConfigSettings.CONTROL_DASH],
			pad_controls[ConfigSettings.CONTROL_DASH]
		],
		Global.ACTION_LIST[Global.ActionList.UP]: [
			key_controls[ConfigSettings.CONTROL_UP],
			pad_controls[ConfigSettings.CONTROL_UP]
		],
		Global.ACTION_LIST[Global.ActionList.DOWN]: [
			key_controls[ConfigSettings.CONTROL_DOWN],
			pad_controls[ConfigSettings.CONTROL_DOWN]
		],
		Global.ACTION_LIST[Global.ActionList.LEFT]: [
			key_controls[ConfigSettings.CONTROL_LEFT],
			pad_controls[ConfigSettings.CONTROL_LEFT]
		],
		Global.ACTION_LIST[Global.ActionList.RIGHT]: [
			key_controls[ConfigSettings.CONTROL_RIGHT],
			pad_controls[ConfigSettings.CONTROL_RIGHT]
		],
		Global.ACTION_LIST[Global.ActionList.RESTART]: [
			key_controls[ConfigSettings.CONTROL_RESTART],
			pad_controls[ConfigSettings.CONTROL_RESTART]
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
	var temp_config_controls = temp_config[ConfigSettings.CONTROLS]
	var temp_config_key_controls = temp_config_controls[ConfigSettings.CONTROLS_KEY]
	var temp_config_pad_controls = temp_config_controls[ConfigSettings.CONTROLS_PAD]

	var default_key_controls = default_controls[ConfigSettings.CONTROLS_KEY]
	var default_pad_controls = default_controls[ConfigSettings.CONTROLS_PAD]

	# Assign all values and substitute the default if it is missing
	var incoming_changes = {
		ConfigSettings.DISPLAY_MODE: temp_config[ConfigSettings.DISPLAY_MODE] if temp_config.has(ConfigSettings.DISPLAY_MODE) else default_settings[ConfigSettings.DISPLAY_MODE],
		ConfigSettings.CONTROLS: {
			ConfigSettings.CONTROLS_KEY: {
				ConfigSettings.CONTROL_UP: temp_config_key_controls[ConfigSettings.CONTROL_UP] if temp_config_key_controls.has(ConfigSettings.CONTROL_UP) else default_key_controls[ConfigSettings.CONTROL_UP],
				ConfigSettings.CONTROL_DOWN: temp_config_key_controls[ConfigSettings.CONTROL_DOWN] if temp_config_key_controls.has(ConfigSettings.CONTROL_DOWN) else default_key_controls[ConfigSettings.CONTROL_DOWN],
				ConfigSettings.CONTROL_LEFT: temp_config_key_controls[ConfigSettings.CONTROL_LEFT] if temp_config_key_controls.has(ConfigSettings.CONTROL_LEFT) else default_key_controls[ConfigSettings.CONTROL_LEFT],
				ConfigSettings.CONTROL_RIGHT: temp_config_key_controls[ConfigSettings.CONTROL_RIGHT] if temp_config_key_controls.has(ConfigSettings.CONTROL_RIGHT) else default_key_controls[ConfigSettings.CONTROL_RIGHT],
				ConfigSettings.CONTROL_JUMP: temp_config_key_controls[ConfigSettings.CONTROL_JUMP] if temp_config_key_controls.has(ConfigSettings.CONTROL_JUMP) else default_key_controls[ConfigSettings.CONTROL_JUMP],
				ConfigSettings.CONTROL_DASH: temp_config_key_controls[ConfigSettings.CONTROL_DASH] if temp_config_key_controls.has(ConfigSettings.CONTROL_DASH) else default_key_controls[ConfigSettings.CONTROL_DASH],
				ConfigSettings.CONTROL_RESTART: temp_config_key_controls[ConfigSettings.CONTROL_RESTART] if temp_config_key_controls.has(ConfigSettings.CONTROL_RESTART) else default_key_controls[ConfigSettings.CONTROL_RESTART],
			},
			ConfigSettings.CONTROLS_PAD: {
				ConfigSettings.CONTROL_UP: temp_config_pad_controls[ConfigSettings.CONTROL_UP] if temp_config_pad_controls.has(ConfigSettings.CONTROL_UP) else default_pad_controls[ConfigSettings.CONTROL_UP],
				ConfigSettings.CONTROL_DOWN: temp_config_pad_controls[ConfigSettings.CONTROL_DOWN] if temp_config_pad_controls.has(ConfigSettings.CONTROL_DOWN) else default_pad_controls[ConfigSettings.CONTROL_DOWN],
				ConfigSettings.CONTROL_LEFT: temp_config_pad_controls[ConfigSettings.CONTROL_LEFT] if temp_config_pad_controls.has(ConfigSettings.CONTROL_LEFT) else default_pad_controls[ConfigSettings.CONTROL_LEFT],
				ConfigSettings.CONTROL_RIGHT: temp_config_pad_controls[ConfigSettings.CONTROL_RIGHT] if temp_config_pad_controls.has(ConfigSettings.CONTROL_RIGHT) else default_pad_controls[ConfigSettings.CONTROL_RIGHT],
				ConfigSettings.CONTROL_JUMP: temp_config_pad_controls[ConfigSettings.CONTROL_JUMP] if temp_config_pad_controls.has(ConfigSettings.CONTROL_JUMP) else default_pad_controls[ConfigSettings.CONTROL_JUMP],
				ConfigSettings.CONTROL_DASH: temp_config_pad_controls[ConfigSettings.CONTROL_DASH] if temp_config_pad_controls.has(ConfigSettings.CONTROL_DASH) else default_pad_controls[ConfigSettings.CONTROL_DASH],
				ConfigSettings.CONTROL_RESTART: temp_config_pad_controls[ConfigSettings.CONTROL_RESTART] if temp_config_pad_controls.has(ConfigSettings.CONTROL_RESTART) else default_pad_controls[ConfigSettings.CONTROL_RESTART],
			}
		}
	}
	
	_settings_config = incoming_changes.duplicate(true)


func save_config() -> void:
	var file := FileAccess.open(USER_PATH, FileAccess.WRITE)
	file.store_var(_settings_config, true)
	file.close()
