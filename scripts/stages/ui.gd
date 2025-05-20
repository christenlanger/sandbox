extends CanvasLayer

signal restart_triggered

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(Global.ACTION_LIST[Global.ActionList.RESTART]):
		restart_triggered.emit()
		
