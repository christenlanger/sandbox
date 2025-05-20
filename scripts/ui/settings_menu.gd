extends Control

const display_modes = {
	"windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
}

@onready var display_mode_container: HBoxContainer = %DisplayModeContainer
@onready var display_scroll: ScrollContainer = %DisplayScroll

var pending_config: Dictionary


# Copy current config and display on screen
func _ready() -> void:
	pending_config = Config.current_config.duplicate(true)
	
	# Set display mode to config when changed
	for child in display_mode_container.get_children():
		if child is Button:
			child.focus_entered.connect(_change_display_setting)
	
	
	# For debugging
	display_mode_container.grab_focus.call_deferred()
	#display_scroll.set_deferred("scroll_horizontal", 0)
	get_viewport().gui_focus_changed.connect(_on_focus_node)

# Change values for pending config by key
func change_setting(key: Config.ConfigSettings, value: Variant):
	pending_config[key] = value


# For debugging
func _on_focus_node(node: Node):
	print(node.name)


## Display mode functions

# Set pending config to currently focused label
func _change_display_setting():
	var node = get_viewport().gui_get_focus_owner()
	
	if node is Button:
		node.button_pressed = true
		change_setting(Config.ConfigSettings.DISPLAY_MODE, display_modes[node.get_meta("display_mode")])


func _on_display_mode_container_focus_entered() -> void:
	display_mode_container.get_child(0).grab_focus.call_deferred()
