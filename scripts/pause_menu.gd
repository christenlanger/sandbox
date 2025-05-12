extends Control

signal pause
signal resume

var _pause_state := false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause_state = not _pause_state
		if _pause_state:
			_pause()
		else:
			_resume()


func _pause() -> void:
	pause.emit()


func _resume() -> void:
	resume.emit()
