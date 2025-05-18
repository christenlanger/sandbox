extends Node

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


func set_default_config() -> void:
	InputMap.load_from_project_settings()
	
	_settings_config = {
		ConfigSettings.DISPLAY_MODE: DisplayServer.WINDOW_MODE_WINDOWED,
		ConfigSettings.CONTROLS: {
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
	}


func apply_default_config() -> void:
	set_default_config()
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
	#var action_list = {
		#Global.action_list[Global.ActionList.JUMP]: [controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_JUMP], controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_JUMP]],
		#Global.action_list[Global.ActionList.DASH]: [controls[ConfigSettings.CONTROLS_KEY][ConfigSettings.CONTROL_DASH], controls[ConfigSettings.CONTROLS_PAD][ConfigSettings.CONTROL_DASH]],
	#}
	
	for action in action_list.keys():
		InputMap.action_erase_events(action)
		for event in action_list[action]:
			InputMap.action_add_event(action, event)
