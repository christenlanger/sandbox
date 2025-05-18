extends OptionsUI

@onready var _state_chart: StateChart = $StateChart
@onready var display_menu: OptionsUI = %DisplayMenu
@onready var input_map_menu: OptionsUI = %InputMapMenu
@onready var input_map_box: PanelContainer = %InputMapBox
@onready var input_map_container: HBoxContainer = %InputMapContainer
@onready var display_container: HBoxContainer = %DisplayContainer

var _config_settings = {}
var _config_changed := false
var _confirm_menu: OptionsUI

# Input actions to display. Note that this is dependent on the display order
# Check for a better implementation in the future
var _input_actions := {
	Global.action_list[Global.ActionList.UP]: "Up",
	Global.action_list[Global.ActionList.LEFT]: "Move Left",
	Global.action_list[Global.ActionList.RIGHT]: "Move Right",
	Global.action_list[Global.ActionList.DOWN]: "Crouch",
	Global.action_list[Global.ActionList.JUMP]: "Jump",
	Global.action_list[Global.ActionList.DASH]: "Dash"
}

var _input_is_gamepad := 0
var _current_input_map_action : String


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
	_config_settings = Config.current_config.duplicate(true)
	
	# Populate the input map
	_update_input_map()
	
	# Update other settings
	display_stored_settings()
	
	# Inform the state chart
	_state_chart.send_event("open")


# Close the menu
func close(option: int = 0) -> void:
	_confirm_close()
	
	##	Previously confirming changes and applying only on exit attempt
	#	All setting changes are now applied immediately to keep UI simple
	#	Previous code is commented out in case there's a change
	# 
	# # If settings were changed, ask to confirm
	# if _config_changed:
	# 	_confirm_menu = load(Global.scene_paths[Global.ScenePaths.UI] + "yes_no_box.tscn").instantiate()
	# 	_confirm_menu.title = "Apply changes?"
	# 	_confirm_menu.cancel.connect(_cancel_close)
	# 	_confirm_menu.confirm.connect(_close_with_config)
	# 	add_child(_confirm_menu)
	# 	_state_chart.send_event("open_modal")
	# else:
	# 	_confirm_close()


# Actually close the window after checks
func _confirm_close() -> void:
	# Close window
	_config_changed = false
	self.visible = false
	_state_chart.send_event("close")
	settings_closed.emit()


# Cancel the close attempt
func _cancel_close(option: int = 0) -> void:
	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()


# Close the settings menu with changed configs
func _close_with_config(option: int) -> void:
	# If signal is true, emit new settings to be handled by parent. Otherwise discard.
	if option:
		settings_updated.emit(_config_settings)
	
	# Close the settings screen regardless
	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()
	_confirm_close()


# Update selected settings
func display_stored_settings() -> void:
	# Display mode
	var display_mode := {
		"Windowed": DisplayServer.WINDOW_MODE_WINDOWED,
		"Fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	}
	
	for mode in display_mode.keys():
		var label := _get_label_from_node(display_container, mode)
		if label and _config_settings[Config.ConfigSettings.DISPLAY_MODE] == display_mode[mode]:
			label.label_settings = Global.label_settings[Global.LabelPresets.SELECTED]


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
		
		# Restore everything to default
		2:
			_confirm_menu = load(Global.scene_paths[Global.ScenePaths.UI] + "yes_no_box.tscn").instantiate()
			_confirm_menu.title = "Reset settings to default?"
			_confirm_menu.cancel.connect(_on_default_settings_cancel)
			_confirm_menu.confirm.connect(_on_default_settings_apply)
			add_child(_confirm_menu)
			_state_chart.send_event("open_modal")
			pass
		
		# Save and close settings menu
		options_count:
			cancel.emit()


# Cancel restore default
func _on_default_settings_cancel(option: int = 0) -> void:
	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()


# Apply restore default
func _on_default_settings_apply(option: int) -> void:
	if option:
		Config.apply_default_config()
		display_stored_settings()
		_update_input_map()

	_state_chart.send_event("close_modal")
	if _confirm_menu:
		_confirm_menu.queue_free()


# Change a specific option
func change_setting(key, value) -> void:
	_config_settings[key] = value
	_config_changed = true


func _on_display_menu_cancel(option: int = 0) -> void:
	_state_chart.send_event("go_back")
	set_current(option)


func _on_display_menu_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") and display_menu.current_option == 0:
		display_menu.cancel.emit(current_option)
	elif event.is_action_pressed("ui_down"):
		display_menu.cancel.emit(current_option + 1)
	else:
		display_menu.handle_input(event)


# Change display based on selection
func _on_display_menu_option_selected(option: int) -> void:
	var options = [
		DisplayServer.WINDOW_MODE_WINDOWED,
		DisplayServer.WINDOW_MODE_FULLSCREEN
	]
	DisplayServer.window_set_mode(options[option])
	
	var label_node_names = ["Windowed", "Fullscreen"]
	for i in label_node_names.size():
		var label_node := _get_label_from_node(display_container, label_node_names[i])
		if label_node and i == option:
			label_node.label_settings = Global.label_settings[Global.LabelPresets.SELECTED]
		else:
			label_node.label_settings = Global.label_settings[Global.LabelPresets.DEFAULT]
	
	change_setting(Config.ConfigSettings.DISPLAY_MODE, options[option])


# Go back to top menu
func _on_input_map_menu_cancel(option: int = 0) -> void:
	input_map_menu._options.map(func(e):
		if e is PanelContainer:
			e.set("theme_override_styles/panel", null)
		return e
	)
	_state_chart.send_event("go_back")
	set_current(option)


# Handle input map menu differently
func _on_navigating_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") and input_map_menu.current_option % 2 == 0:
		input_map_menu._goto_next_option()
	elif event.is_action_pressed("ui_left"):
		if input_map_menu.current_option % 2 == 1:
			input_map_menu._goto_prev_option()
		else:
			input_map_menu.cancel.emit(current_option)
	elif event.is_action_pressed("ui_down"):
		if not input_map_menu._goto_next_option(2):
			input_map_menu.cancel.emit(current_option + 1)
	elif event.is_action_pressed("ui_up"):
		if not input_map_menu._goto_prev_option(2):
			input_map_menu.cancel.emit(current_option)
	elif event.is_action_pressed("ui_accept"):
		input_map_menu.option_selected.emit(input_map_menu.current_option)
	elif event.is_action_pressed("ui_cancel"):
		input_map_menu.cancel.emit(current_option)


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
	_current_input_map_action = _input_actions.keys()[floor(option / 2)]
	_state_chart.send_event("await_input")


func _on_awaiting_input_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		input_map_box.visible = false
		_state_chart.send_event("cancel_input")
	elif _remap_input(event):
		input_map_box.visible = false
		_update_input_map()
		_state_chart.send_event("cancel_input")
	else:
		# Invalid input
		pass


# Update the text for the input mapping
func _update_input_map() -> void:
	# Fill all keyboard maps
	for key_input in input_map_container.find_children("key_*", "Label"):
		var action = key_input.name.right(-4)
		for input_event in InputMap.action_get_events(action):
			if input_event is InputEventKey:
				key_input.text = _shorten_event_name(input_event.as_text())
		
	# Fill all gamepad maps
	for pad_input in input_map_container.find_children("pad_*", "Label"):
		var action = pad_input.name.right(-4)
		for input_event in InputMap.action_get_events(action):
			if input_event is InputEventJoypadButton:
				pad_input.text = _shorten_event_name(input_event.as_text())


# Check if we can remap the input
func _remap_input(event: InputEvent) -> bool:
	var is_valid := false
	if event.is_pressed() and not event.is_echo():
		print(event)
		if (event is InputEventKey and not _input_is_gamepad) or (event is InputEventJoypadButton and _input_is_gamepad):
			var mapped = _mapped_action(event)
			var action_events = InputMap.action_get_events(_current_input_map_action)
			var prev_action_events = action_events.duplicate(true)
			
			# Make sure current key or button being mapped is limited to that type
			for i in action_events.size():
				if action_events[i] is InputEventKey and event is InputEventKey:
					action_events[i] = event
				elif action_events[i] is InputEventJoypadButton and event is InputEventJoypadButton:
					action_events[i] = event
			
			# Add new binding if the new key doesn't match an existing bind.
			if _current_input_map_action:
				InputMap.action_erase_events(_current_input_map_action)
				for action_event in action_events:
					InputMap.action_add_event(_current_input_map_action, action_event)
				
				# Swap bindings with existing ones
				if mapped != "":
					var old_action_events = InputMap.action_get_events(mapped)
					
					for prev_event in prev_action_events:
						for i in old_action_events.size():
							if old_action_events[i] is InputEventKey and prev_event is InputEventKey:
								old_action_events[i] = prev_event
							elif old_action_events[i] is InputEventJoypadButton and prev_event is InputEventJoypadButton:
								old_action_events[i] = prev_event
					
					InputMap.action_erase_events(mapped)
					for action_event in old_action_events:
						InputMap.action_add_event(mapped, action_event)
				
				is_valid = true
		
	return is_valid


func _get_label_from_node(node: Node, name: String) -> Label:
	var child = node.find_child(name)
	
	if child is Label:
		return child
	
	return null


func _shorten_event_name(event_name: String) -> String:
	var short_name := event_name
	
	# Match patterns for keyboard
	if event_name.match("* (Physical)"):
		short_name = event_name.left(-11)
	elif event_name.match("Joypad Button*"):
		short_name = event_name.get_slice(" ", 2)
	
	return short_name


func _mapped_action(event: InputEvent) -> String:
	var action_list := InputMap.get_actions()
	
	for action in action_list:
		if not action.begins_with("ui_") and InputMap.action_has_event(action, event):
			return action
	return ""
