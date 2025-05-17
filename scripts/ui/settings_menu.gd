extends OptionsUI

@onready var _state_chart: StateChart = $StateChart
@onready var display_menu: OptionsUI = %DisplayMenu
@onready var input_map_menu: OptionsUI = %InputMapMenu
@onready var input_map_box: PanelContainer = %InputMapBox
@onready var input_map_container: HBoxContainer = %InputMapContainer

var _config_settings = {}
var _config_changed := false
var _confirm_menu: OptionsUI

# Input actions to display. Note that this is dependent on the display order
# Check for a better implementation in the future
var _input_actions := {
	Global.action_list[Global.ActionList.LEFT]: "Move Left",
	Global.action_list[Global.ActionList.RIGHT]: "Move Right",
	Global.action_list[Global.ActionList.DOWN]: "Crouch",
	Global.action_list[Global.ActionList.JUMP]: "Jump",
	Global.action_list[Global.ActionList.DASH]: "Dash"
}

var _input_is_gamepad := 0



signal settings_updated(options: Dictionary)
signal settings_closed

# On load
func _ready() -> void:
	super()


# Handle input on top level menu
func _on_active_state_input(event: InputEvent) -> void:
	# Pressing right is equivalent to confirm if not on the last option (Quit)
	if event.is_action_pressed("ui_right") and current_option != _options.size() - 1:
		option_selected.emit(current_option)
	else:
		handle_input(event)


# Open the menu
func open() -> void:
	self.visible = true
	
	# Grab the current settings
	_config_settings = Config.current_config.duplicate()
	
	# Populate the input map
	_update_input_map()
	
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


# Handle options
func _on_option_selected(option: int) -> void:
	var options_count = _options.size() - 1
	match option:
		# Display setting
		0 when display_menu.is_enabled():
			_state_chart.send_event("open_display")
			display_menu.set_current(0)
		
		# Input mapping
		1:
			_state_chart.send_event("open_input_map")
			input_map_menu.set_current(0)
		
		# Save settings without closing
		2 when _config_changed:
			_config_changed = false
			settings_updated.emit(_config_settings)
			# todo: confirmation dialog
		
		# Close settings menu
		options_count:
			cancel.emit()


# Change a specific option
func change_setting(key, value) -> void:
	_config_settings[key] = value
	_config_changed = true


func _on_display_menu_cancel() -> void:
	_state_chart.send_event("go_back")
	set_current(0)


func _on_display_menu_state_input(event: InputEvent) -> void:
	display_menu.handle_input(event)


func _on_display_menu_option_selected(option: int) -> void:
	var options = [
		Config.DisplayPresets.RESOLUTION_1280_720,
		Config.DisplayPresets.RESOLUTION_FULLSCREEN
	]
	change_setting(Config.ConfigSettings.DISPLAY_RESOLUTION, options[option])
	_on_display_menu_cancel()


# Go back to top menu
func _on_input_map_menu_cancel() -> void:
	input_map_menu._options.map(func(e):
		if e is PanelContainer:
			e.set("theme_override_styles/panel", null)
		return e
	)
	_state_chart.send_event("go_back")
	set_current(1)


# Handle input map menu differently
func _on_navigating_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") and input_map_menu.current_option % 2 == 0:
		input_map_menu._goto_next_option()
	elif event.is_action_pressed("ui_left") and input_map_menu.current_option % 2 == 1:
		input_map_menu._goto_prev_option()
	elif event.is_action_pressed("ui_down"):
		input_map_menu._goto_next_option(2)
	elif event.is_action_pressed("ui_up"):
		input_map_menu._goto_prev_option(2)
	elif event.is_action_pressed("ui_accept"):
		input_map_menu.option_selected.emit(input_map_menu.current_option)
	elif event.is_action_pressed("ui_cancel"):
		input_map_menu.cancel.emit()


# Highlight the current action to be mapped
func _on_input_map_menu_option_highlighted(option: int) -> void:
	for panel in input_map_menu._options:
		var panel_style: StyleBox = Global.stylebox_settings[Global.StyleBoxPresets.HIGHLIGHTED]
		if panel is PanelContainer:
			if input_map_menu._options.find(panel) == option:
				panel.set("theme_override_styles/panel", panel_style)
			else:
				panel.set("theme_override_styles/panel", null)


# Trigger input remapping
func _on_input_map_menu_option_selected(option: int) -> void:
	# Check if input being remapped is for keyboard or gamepad
	_input_is_gamepad = option % 2
	
	var type_display := "button" if _input_is_gamepad else "key"
	
	input_map_box.get_node("VBoxContainer/InputType").text = "Press a " + type_display + " for"
	input_map_box.get_node("VBoxContainer/InputAction").text = _input_actions.values()[floor(option / 2)]
	
	input_map_box.visible = true
	_state_chart.send_event("await_input")


func _on_awaiting_input_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		input_map_box.visible = false
		_state_chart.send_event("cancel_input")
	else:
		_remap_input(event)


# Update the text for the input mapping
func _update_input_map() -> void:
	# Fill all keyboard maps
	for key_input in input_map_container.find_children("key_*", "Label"):
		var action = key_input.name.right(-4)
		for input_event in InputMap.action_get_events(action):
			if input_event is InputEventKey:
				key_input.text = input_event.as_text()
		
	# Fill all gamepad maps
	for pad_input in input_map_container.find_children("pad_*", "Label"):
		var action = pad_input.name.right(-4)
		for input_event in InputMap.action_get_events(action):
			if input_event is InputEventJoypadButton:
				pad_input.text = input_event.as_text()


# Check if we can remap the input
func _remap_input(event):
	pass


func _get_label_from_node(node: Node, name: String) -> Label:
	var child = node.find_child(name)
	
	if child is Label:
		return child
	
	return null


func _shorten_event_name(event_name: String) -> String:
	
	return event_name
