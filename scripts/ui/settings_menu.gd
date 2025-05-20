extends Control

const display_modes = {
	"windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
}

signal closed
signal send_settings(config: Dictionary)

@onready var state_chart: StateChart = $StateChart
@onready var tab_container: TabContainer = %TabContainer
@onready var display_mode_container: HBoxContainer = %DisplayModeContainer
@onready var display_scroll: ScrollContainer = %DisplayScroll
@onready var controls_container: GridContainer = %ControlsContainer

var pending_config: Dictionary
var _has_changed: bool = false

# For use with input map handling
var _current_input_node: Button
var _action_reference = {
	Global.ACTION_LIST[Global.ActionList.UP]: Config.ConfigSettings.CONTROL_UP,
	Global.ACTION_LIST[Global.ActionList.DOWN]: Config.ConfigSettings.CONTROL_DOWN,
	Global.ACTION_LIST[Global.ActionList.LEFT]: Config.ConfigSettings.CONTROL_LEFT,
	Global.ACTION_LIST[Global.ActionList.RIGHT]: Config.ConfigSettings.CONTROL_RIGHT,
	Global.ACTION_LIST[Global.ActionList.JUMP]: Config.ConfigSettings.CONTROL_JUMP,
	Global.ACTION_LIST[Global.ActionList.DASH]: Config.ConfigSettings.CONTROL_DASH,
	Global.ACTION_LIST[Global.ActionList.RESTART]: Config.ConfigSettings.CONTROL_RESTART,
}

# Copy current config and display on screen
func _ready() -> void:
	pending_config = Config.current_config.duplicate(true)
	
	# Connect tab container to signals
	tab_container.tab_changed.connect(_on_tab_container_tab_changed)

	# Call functions to display current settings in screen
	_display_mode_settings()
	_input_map_settings()

	# Connect key buttons to the input mapping function
	for button in controls_container.get_children():
		if button is Button:
			button.pressed.connect(open_input_map)
	
	# For debugging
	display_mode_container.grab_focus.call_deferred()
	#display_scroll.set_deferred("scroll_horizontal", 0)
	
	# Uncomment to view nodes being focused on output window
	# get_viewport().gui_focus_changed.connect(_on_focus_node)


# Focus on first child inside the tab that can be focused
func _on_tab_container_tab_changed(_tab: int) -> void:
	var nodes := tab_container.get_tab_control(_tab).find_children("*")
	for child in nodes:
		if child is Control and child.focus_mode == FOCUS_ALL:
			print(child.name)
			child.grab_focus.call_deferred()
			break


# Change values for pending config by key
func change_setting(key: Config.ConfigSettings, value: Variant) -> void:
	pending_config[key] = value
	_has_changed = true


# Get setting value for provided key
func get_setting(key: Config.ConfigSettings) -> Variant:
	if pending_config.has(key):
		return pending_config[key]
	return null


# For debugging
func _on_focus_node(node: Node):
	print(node.name)


## Display mode functions

# Display current settings from retrieved variable
func _display_mode_settings() -> void:
	var display_mode = get_setting(Config.ConfigSettings.DISPLAY_MODE)
	for child in display_mode_container.get_children():
		if child is Button:
			var button_meta_value = child.get_meta("display_mode")
			if display_modes[button_meta_value] == display_mode:
				child.button_pressed = true
			child.pressed.connect(_change_display_setting)

# Store selected display setting to pending config
func _change_display_setting() -> void:
	var node = get_viewport().gui_get_focus_owner()
	
	if node is Button:
		change_setting(Config.ConfigSettings.DISPLAY_MODE, display_modes[node.get_meta("display_mode")])


# Focus on first button
func _on_display_mode_container_focus_entered() -> void:
	display_mode_container.get_child(0).grab_focus.call_deferred()

## Input mapping functions

# Input map settings
func _input_map_settings() -> void:
	var input_map = get_setting(Config.ConfigSettings.CONTROLS)
	var key_input_map = input_map[Config.ConfigSettings.CONTROLS_KEY]
	var pad_input_map = input_map[Config.ConfigSettings.CONTROLS_PAD]

	for action in _action_reference.keys():
		var key_btn = controls_container.get_node("key_" + action)
		var key_event = key_input_map[_action_reference[action]]
		var pad_btn = controls_container.get_node("pad_" + action)
		var pad_event = pad_input_map[_action_reference[action]]
		key_btn.text = _input_shortname(key_event.as_text())
		key_btn.set_meta("input_event", key_event)
		pad_btn.text = _input_shortname(pad_event.as_text())
		pad_btn.set_meta("input_event", pad_event)


# Open the input mapper for a key
func open_input_map() -> void:
	var node = get_viewport().gui_get_focus_owner()
	_current_input_node = node
	_current_input_node.release_focus()
	state_chart.send_event("start_input")


func _input_shortname(text: String) -> String:
	var regex = RegEx.new()
	var result = ""
	if text.begins_with("Joypad Button"):
		result = "Button " + text.get_slice(" ", 2)
	elif text.begins_with("Joypad Motion"):
		var motion_text := text.split(" with Value ")
		var axis := motion_text[0].right(7)
		var strength := float(motion_text[1])
		if motion_text[0].match("*Left Stick*"):
			if axis.match("X-Axis*"):
				if strength >= 0.5:
					result += "LS(Right)"
				elif strength <= -0.5:
					result += "LS(Left)"
			elif axis.match("Y-Axis*"):
				if strength >= 0.5:
					result += "LS(Down)"
				elif strength <= -0.5:
					result += "LS(Up)"
		elif motion_text[0].match("*Right Stick*"):
			if axis.match("X-Axis*"):
				if strength >= 0.5:
					result += "RS(Right)"
				elif strength <= -0.5:
					result += "RS(Left)"
			elif axis.match("Y-Axis*"):
				if strength >= 0.5:
					result += "RS(Down)"
				elif strength <= -0.5:
					result += "RS(Up)"
		else:
			result = text
	else:
		result = text
	return result

# Awaiting for event while mapping inputs
func _on_awaiting_input_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		state_chart.send_event("end_input")
	elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var action_prefix := "key_" if event is InputEventKey else "pad_"
		var action_type := Config.ConfigSettings.CONTROLS_KEY if event is InputEventKey else Config.ConfigSettings.CONTROLS_PAD
		
		if _current_input_node.name.begins_with(action_prefix):
			# Mark config change if we actually changed it
			var action_reference = _action_reference[_current_input_node.name.right(-4)]
			var input_event_to_change = pending_config[Config.ConfigSettings.CONTROLS][action_type][action_reference]
			if _input_shortname(input_event_to_change.as_text()) != _input_shortname(event.as_text()):
				_has_changed = true
			
			# Check if current key is assigned anywhere else
			var existing_map: Button = get_btn_with_map(event)
			if (existing_map):
				var action_swap_reference = _action_reference[existing_map.name.right(-4)]
				pending_config[Config.ConfigSettings.CONTROLS][action_type][action_swap_reference] = input_event_to_change
				existing_map.text = _current_input_node.text
				existing_map.set_meta("input_event", _current_input_node.get_meta("input_event"))
			
			pending_config[Config.ConfigSettings.CONTROLS][action_type][action_reference] = event
			_current_input_node.set_meta("input_event", event)
			_current_input_node.text = _input_shortname(event.as_text())
			state_chart.send_event("end_input")
		
	get_viewport().set_input_as_handled()


# Input mapping has ended and button should be refocused
func _on_on_enabled_taken() -> void:
	_current_input_node.grab_focus()


# Checks if current key is assigned to the displayed input map
# and returns the node that contains it.
func get_btn_with_map(event: InputEvent) -> Button:
	for child in controls_container.get_children():
		if child is Button and child.text != _current_input_node.text and child.text == _input_shortname(event.as_text()):
			return child
	return null

## State handling

# Inputs while there's no open modal dialog
func _on_enabled_state_input(event: InputEvent) -> void:
	var current_tab = tab_container.current_tab

	if event.is_action_pressed("ui_prev_page"):
		if current_tab > 0:
			tab_container.current_tab -= 1
	elif event.is_action_pressed("ui_next_page"):
		if current_tab < tab_container.get_tab_count():
			tab_container.current_tab += 1
	elif event.is_action_pressed("ui_cancel"):
		_attempt_to_close()

## Handle closing of the window and saving config settings

# Run checks before closing the window
func _attempt_to_close() -> void:
	_send_settings()
	closed.emit.call_deferred()

# Send the config variable to be processed
func _send_settings() -> void:
	send_settings.emit(pending_config)
