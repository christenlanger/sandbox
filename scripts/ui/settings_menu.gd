extends OptionsUI

@onready var _state_chart: StateChart = $StateChart

var _config_settings = {}
var _config_changed := false
var _confirm_menu: OptionsUI

signal settings_updated(options: Dictionary)
signal settings_closed

# On load
func _ready() -> void:
	super()


# Handle input
func _on_active_state_input(event: InputEvent) -> void:
	handle_input(event)


# Open the menu
func open() -> void:
	self.visible = true
	
	# Grab the current settings
	_config_settings = Config.current_config.duplicate()
	
	# Inform the state chart
	_state_chart.send_event("open")


# Close the menu
func close() -> void:
	# If settings were changed, ask to confirm
	if _config_changed:
		_confirm_menu = load(Global.scene_paths[Global.ScenePaths.UI] + "yes_no_box.tscn").instantiate()
		_confirm_menu.title = "Apply changes?"
		_confirm_menu.cancel.connect(_cancel_close)
		_confirm_menu.confirm.connect(_close_with_config)
		add_child(_confirm_menu)
		_state_chart.send_event("open_modal")
	else:
		_confirm_close()


# Actually close the window after checks
func _confirm_close() -> void:
	# Close window
	_config_changed = false
	self.visible = false
	_state_chart.send_event("close")
	settings_closed.emit()


# Cancel the close attempt
func _cancel_close() -> void:
	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()


# Close the settings menu with changed configs
func _close_with_config(option) -> void:
	# If signal is true, emit new settings to be handled by parent. Otherwise discard.
	if option:
		settings_updated.emit(_config_settings)
	
	# Close the settings screen regardless
	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()
	_confirm_close()


# Reset selections
func reset() -> void:
	set_current(0)
	_on_option_highlighted(0)


# Handle options
func _on_option_selected(option: int) -> void:
	match option:
		# Set to Windowed
		0:
			change_setting(Config.ConfigSettings.DISPLAY_RESOLUTION, Config.DisplayPresets.RESOLUTION_1280_720)
		1:
			change_setting(Config.ConfigSettings.DISPLAY_RESOLUTION, Config.DisplayPresets.RESOLUTION_FULLSCREEN)
		# Close settings menu
		3:
			cancel.emit()


# Handle highlighting
func _on_option_highlighted(option: int) -> void:
	for label in _options:
		if label.get_index() == _options[option].get_index():
			label.label_settings = Global.label_settings[Global.LabelPresets.SELECTED]
		else:
			label.label_settings = Global.label_settings[Global.LabelPresets.DEFAULT]


func change_setting(key, value) -> void:
	_config_settings[key] = value
	_config_changed = true
