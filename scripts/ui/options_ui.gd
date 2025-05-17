class_name OptionsUI

extends Control

# Be able to open the UI if enabled
@export var _enabled: bool = true

# Visible on load
@export var _visible_on_load: bool = false

# Set of nodes as options. Change typing if you want to use other nodes
@export var _options: Array[Node]

# Set cursor and behavior
@export var _cursor: Node
@export var _wrap_around: bool = true

# Variables for cursor positioning
enum AttachToCursor {X, Y, BOTH}
@export var _attach_cursor_to_option: AttachToCursor
@export var _attach_offset: Vector2

# For checking which UI keys to listen to
@export var _vertical_navigation: bool = true
@export var _horizontal_navigation: bool = true

signal option_highlighted(option: int)
signal option_selected(option: int)
signal cancel

var current_option := 0


# Initialize
func _ready() -> void:
	self.visible = _visible_on_load


# Call to handle input events
func handle_input(event: InputEvent) -> void:
	if _vertical_navigation and event.is_action_pressed("ui_up") or (_horizontal_navigation and event.is_action_pressed("ui_left")):
		_goto_prev_option()
	elif _vertical_navigation and event.is_action_pressed("ui_down") or (_horizontal_navigation and event.is_action_pressed("ui_right")):
		_goto_next_option()
	elif event.is_action_pressed("ui_accept"):
		option_selected.emit(current_option)
	elif event.is_action_pressed("ui_cancel"):
		cancel.emit()


# Move selection to previous option
func _goto_prev_option(step: int = 1) -> void:
	if _wrap_around and current_option - step < 0:
		current_option = _options.size() - 1
	elif current_option - step >= 0:
		current_option -= step
	option_highlighted.emit(current_option)
	_set_cursor_position(current_option)


# Move selection to next option
func _goto_next_option(step: int = 1) -> void:
	if _wrap_around and current_option + step >= _options.size():
		current_option = 0
	elif current_option + step < _options.size():
		current_option += step
	option_highlighted.emit(current_option)
	_set_cursor_position(current_option)


# Move cursor to current option
func _set_cursor_position(option: int) -> void:
	if _cursor and _options[option]:
		var pos: Vector2 = _options[option].get_global_transform_with_canvas().get_origin()
		
		if _attach_cursor_to_option == AttachToCursor.X or _attach_cursor_to_option == AttachToCursor.BOTH:
			_cursor.position.x = pos.x + _attach_offset.x
		if _attach_cursor_to_option == AttachToCursor.Y or _attach_cursor_to_option == AttachToCursor.BOTH:
			_cursor.position.y = pos.y + _attach_offset.y


# Return _enabled for other nodes
func is_enabled() -> bool:
	return _enabled


# Set current option
func set_current(value: int) -> void:
	current_option = value
	option_highlighted.emit(current_option)
	_set_cursor_position.call_deferred(current_option)
