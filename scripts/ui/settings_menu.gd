extends Control

const display_modes = {
	"windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
}

signal closed
signal send_settings(config: Dictionary)

@onready var display_mode_container: HBoxContainer = %DisplayModeContainer
@onready var display_scroll: ScrollContainer = %DisplayScroll
@onready var tab_container: TabContainer = %TabContainer

var pending_config: Dictionary
var _has_changed: bool = false

# Copy current config and display on screen
func _ready() -> void:
	pending_config = Config.current_config.duplicate(true)
	
	# Call functions to display current settings in screen
	_display_mode_settings()
	

	# For debugging
	display_mode_container.grab_focus.call_deferred()
	#display_scroll.set_deferred("scroll_horizontal", 0)
	get_viewport().gui_focus_changed.connect(_on_focus_node)


# Focus on first child inside the tab that can be focused
func _on_tab_container_tab_changed(_tab: int) -> void:
	var nodes := tab_container.get_current_tab_control().find_children("*")
	for child in nodes:
		if child is Control and child.focus_mode == FOCUS_ALL:
			print(child.name)
			child.grab_focus.call_deferred()
			break;


# Change values for pending config by key
func change_setting(key: Config.ConfigSettings, value: Variant) -> void:
	pending_config[key] = value


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
