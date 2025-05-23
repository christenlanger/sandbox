class_name PauseMenu

extends Control

@export var enabled: bool = true

@onready var state_chart: StateChart = $StateChart
@onready var btn_resume: Button = $VBoxContainer/Resume
@onready var btn_settings: Button = $VBoxContainer/Settings
@onready var btn_quit_to_desktop: Button = $"VBoxContainer/Quit to Desktop"


signal closed
signal open_settings

var is_paused := false


# Wait for pause key to be pressed
func _on_closed_state_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed("pause"):
		set_paused(true)


# Close on cancel
func _on_active_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		set_paused(false)


# Toggle pause
func set_paused(paused: bool) -> void:
	is_paused = paused
	visible = paused
	get_tree().paused = paused
	
	if paused:
		state_chart.send_event("open")
	else:
		state_chart.send_event("close")
		closed.emit()


# Pause menu has just been opened
func _on_open() -> void:
	btn_resume.grab_focus()


# Resume game (unpause)
func _on_resume_pressed() -> void:
	set_paused(false)


# Quit game
func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()


# Open settings. Turn on modal state to prevent further inputs
func _on_settings_pressed() -> void:
	state_chart.send_event("open_modal")
	open_settings.emit()


# Close settings. Connect this to a signal to release modal state
func close_settings() -> void:
	state_chart.send_event("close_modal")
	btn_settings.grab_focus()
