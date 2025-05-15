extends OptionsUI

@onready var _settings_menu: Control = $SettingsMenu

var _label_settings := {}
var _is_paused := false

enum LabelPresets {DEFAULT, SELECTED}

func _ready() -> void:
	_label_settings = {
		LabelPresets.DEFAULT: load("res://assets/ui_label_option.tres"),
		LabelPresets.SELECTED: load("res://assets/ui_label_option_selected.tres"),
	}


# Open pause menu on specific key but prevent super if not paused
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _is_paused:
		_toggle_pause(true)
	else:
		super(event)


# Signal handler for exiting pause
func _resume() -> void:
	_toggle_pause(false)


# Toggle pause method
func _toggle_pause(is_paused: bool) -> void:
	_is_paused = is_paused
	_enabled = is_paused
	self.visible = is_paused
	get_tree().paused = is_paused


# Handle options
func _on_option_selected(option: int) -> void:
	match option:
		# Resume
		0:
			_resume()
		# Settings
		1:
			pass
		# Quit game
		2:
			get_tree().quit()


# Handle highlighting
func _on_option_highlighted(option: int) -> void:
	for label in _options:
		if label.get_index() == _options[option].get_index():
			label.label_settings = _label_settings[LabelPresets.SELECTED]
		else:
			label.label_settings = _label_settings[LabelPresets.DEFAULT]
