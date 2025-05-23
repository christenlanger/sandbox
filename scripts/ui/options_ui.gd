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
signal cancel(option: int)

var current_option := 0

# Fix for joypad handling
var input_rest := false

# Initialize
func _ready() -> void:
	self.visible = _visible_on_load


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		
		pass


# Call to handle input events
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		option_selected.emit(current_option)
	elif event.is_action_pressed("ui_cancel"):
		cancel.emit()
	else:
		if _vertical_navigation:
			if event.is_action_pressed("ui_up"):
				if event is InputEventKey or (event is InputEventJoypadMotion and valid_joystick_input(event, "ui_up")):
					_goto_prev_option()
			elif event.is_action_pressed("ui_down"):
				if event is InputEventKey or (event is InputEventJoypadMotion and valid_joystick_input(event, "ui_down")):
					_goto_next_option()
		if _horizontal_navigation:
			if event.is_action_pressed("ui_left"):
				if event is InputEventKey or (event is InputEventJoypadMotion and valid_joystick_input(event, "ui_left")):
					_goto_prev_option()
			elif event.is_action_pressed("ui_right"):
				if event is InputEventKey or (event is InputEventJoypadMotion and valid_joystick_input(event, "ui_right")):
					_goto_next_option()


# Fix for joypad handling
func valid_joystick_input(event: InputEventJoypadMotion, action: String) -> bool:
	if !input_rest and InputMap.action_has_event(action, event):
		var timer: Timer = Timer.new()
		timer.timeout.connect(func():
			input_rest = false
			timer.queue_free.call_deferred()
		)
		add_child(timer)
		timer.start(0.1)
		input_rest = true
		print(event, ", ", action)
		return true
	return false


# Move selection to previous option
func _goto_prev_option(step: int = 1) -> bool:
	var changed := false
	
	if _wrap_around and current_option - step < 0:
		current_option = _options.size() - 1
		changed = true
	elif current_option - step >= 0:
		current_option -= step
		changed = true
	option_highlighted.emit(current_option)
	_set_cursor_position(current_option)
	
	return changed


# Move selection to next option
func _goto_next_option(step: int = 1) -> bool:
	var changed := false
	
	if _wrap_around and current_option + step >= _options.size():
		current_option = 0
		changed = true
	elif current_option + step < _options.size():
		current_option += step
		changed = true
	option_highlighted.emit(current_option)
	_set_cursor_position(current_option)
	
	return changed


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
