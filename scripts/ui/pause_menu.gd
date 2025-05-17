extends OptionsUI

@onready var settings_menu: OptionsUI = $SettingsMenu
@onready var _state_chart: StateChart = $StateChart

var _is_paused := false


func _ready() -> void:
	if _enabled:
		set_current(0)
		super()



func _on_active_state_input(event: InputEvent) -> void:
	handle_input(event)


func _on_closed_state_input(event: InputEvent) -> void:
	if _enabled and event.is_action_pressed("ui_cancel"):
		_state_chart.send_event("open")
		set_current(0)
		_toggle_pause(true)


# Signal handler for exiting pause
func _resume() -> void:
	_state_chart.send_event("close")
	_toggle_pause(false)


# Toggle pause method
func _toggle_pause(is_paused: bool) -> void:
	_is_paused = is_paused
	self.visible = is_paused
	get_tree().paused = is_paused


# Handle options
func _on_option_selected(option: int) -> void:
	match option:
		# Resume
		0:
			_resume()
		# Settings
		1 when settings_menu.is_enabled():
			settings_menu.open()
			_state_chart.send_event("open_modal")
		# Quit game
		2:
			get_tree().quit()


# Handle highlighting
func _on_option_highlighted(option: int) -> void:
	for label in _options:
		if label.get_index() == _options[option].get_index():
			label.label_settings = Global.label_settings[Global.LabelPresets.SELECTED]
		else:
			label.label_settings = Global.label_settings[Global.LabelPresets.DEFAULT]


# When the settings menu is closed
func _on_settings_menu_settings_closed() -> void:
	settings_menu.reset()
	_state_chart.send_event("close_modal")
