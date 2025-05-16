extends OptionsUI

@onready var _state_chart: StateChart = $StateChart

var _config_settings = {}

signal settings_updated(options: Dictionary)

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
	_config_settings = Config.current_config	
	
	# Inform the state chart
	_state_chart.send_event("open")


# Close the menu
func close() -> void:
	# Emit new settings to be handled by parent
	settings_updated.emit(_config_settings)
	
	# Close window
	self.visible = false
	_state_chart.send_event("close")


# Reset selections
func reset() -> void:
	set_current(0)
	_on_option_highlighted(0)


# Handle options
func _on_option_selected(option: int) -> void:
	match option:
		# Set to Windowed
		0:
			_config_settings[Config.ConfigSettings.DISPLAY_RESOLUTION] = Config.DisplayPresets.RESOLUTION_1280_720
		1:
			_config_settings[Config.ConfigSettings.DISPLAY_RESOLUTION] = Config.DisplayPresets.RESOLUTION_FULLSCREEN
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
