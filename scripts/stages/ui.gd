class_name UI

extends CanvasLayer

signal restart_triggered

var enabled: bool = false


func _input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed(Global.ACTION_LIST[Global.ActionList.RESTART]):
		restart_triggered.emit()
