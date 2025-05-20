extends OptionsUI

@onready var settings_menu: OptionsUI = $SettingsMenu
@onready var _state_chart: StateChart = $StateChart

var _is_paused := false


func _ready() -> void:
	if _enabled:
		set_current(0)
		super()


func _on_active_state_input(event: InputEvent) -> void:
	# Handle pause action only for pause menu
	if event.is_action_pressed(Global.ACTION_LIST[Global.ActionList.PAUSE]):
		cancel.emit()
	else:
		handle_input(event)


func _on_closed_state_input(event: InputEvent) -> void:
	if _enabled and event.is_action_pressed(Global.ACTION_LIST[Global.ActionList.PAUSE]):
		_state_chart.send_event("open")
		set_current(0)
		_toggle_pause(true)


# Signal handler for exiting pause
func _resume(option: int = 0) -> void:
	_state_chart.send_event("close")
	_toggle_pause(false)


# Toggle pause method
func _toggle_pause(is_paused: bool) -> void:
	_is_paused = is_paused
	self.visible = is_paused
	get_tree().paused = is_paused


# Handle options
func _on_option_selected(option: int) -> void:
	var option_count = _options.size() - 1
	match option:
		# Resume
		0:
			_resume()
		# Settings
		1 when settings_menu.is_enabled():
			settings_menu.set_current(0)
			settings_menu.open()
			_state_chart.send_event("open_modal")
		# Quit game
		option_count:
			get_tree().quit()


# Handle highlighting
func _on_option_highlighted(option: int) -> void:
	for node in _options:
		var label := _find_first_label(node)
		if label:
			if node.get_index() == _options[option].get_index():
				label.label_settings = Global.label_settings[Global.LabelPresets.SELECTED]
			else:
				label.label_settings = Global.label_settings[Global.LabelPresets.DEFAULT]


# When the settings menu is closed
func _on_settings_menu_settings_closed() -> void:
	settings_menu.reset()
	_state_chart.send_event("close_modal")


# Find first label inside node
func _find_first_label(node: Node) -> Label:
	if node is Label:
		return node
	else:
		for child in node.get_children():
			if child is Label:
				return child
	return null
