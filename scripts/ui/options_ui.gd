class_name OptionsUI

extends Control

@onready var _state_chart: StateChart = $StateChart

# Set of labels as options. Change typing if you want to use other nodes
@export var _options: Array[Label]

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

var _enabled := false
var _current_option := 0


# Handle input events
func _input(event: InputEvent) -> void:
	if _enabled:
		if _vertical_navigation and event.is_action_pressed("ui_up") or (_horizontal_navigation and event.is_action_pressed("ui_left")):
			_goto_prev_option()
		elif _vertical_navigation and event.is_action_pressed("ui_down") or (_horizontal_navigation and event.is_action_pressed("ui_right")):
			_goto_next_option()
		elif event.is_action_pressed("ui_accept"):
			option_selected.emit(_current_option)
		elif event.is_action_pressed("ui_cancel"):
			cancel.emit()


# Move selection to previous option
func _goto_prev_option() -> void:
	_current_option -= 1
	if _current_option < 0:
		_current_option = _options.size() - 1 if _wrap_around else 0
	option_highlighted.emit(_current_option)
	_set_cursor_position()


# Move selection to next option
func _goto_next_option() -> void:
	_current_option += 1
	if _current_option >= _options.size():
		_current_option = 0 if _wrap_around else _options.size() - 1
	option_highlighted.emit(_current_option)
	_set_cursor_position()


# Move cursor to current option
func _set_cursor_position() -> void:
	if _cursor:
		if _attach_cursor_to_option == AttachToCursor.X or _attach_cursor_to_option == AttachToCursor.BOTH:
			_cursor.position.x = _options[_current_option].position.x + _attach_offset.x
		if _attach_cursor_to_option == AttachToCursor.Y or _attach_cursor_to_option == AttachToCursor.BOTH:
			_cursor.position.y = _options[_current_option].position.y + _attach_offset.y
