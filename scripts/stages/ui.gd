extends CanvasLayer

signal restart_triggered

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(Global.action_list[Global.ActionList.RESTART]):
		restart_triggered.emit()
		
