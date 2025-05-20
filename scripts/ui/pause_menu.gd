extends Control

@export var enabled: bool = true

@onready var state_chart: StateChart = $StateChart
@onready var btn_resume: Button = $VBoxContainer/Resume
@onready var btn_settings: Button = $VBoxContainer/Settings
@onready var btn_quit_to_desktop: Button = $"VBoxContainer/Quit to Desktop"


signal closed

var is_paused := false


# Wait for pause key to be pressed
func _on_closed_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(true)


# Close on cancel
func _on_active_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		set_paused(false)


# Toggle pause
func set_paused(is_paused: bool) -> void:
	is_paused = is_paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		state_chart.send_event("open")
	else:
		state_chart.send_event("close")


# Pause menu has just been opened
func _on_open() -> void:
	btn_resume.grab_focus()


# Resume game (unpause)
func _on_resume_pressed() -> void:
	set_paused(false)


# Quit game
func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()
