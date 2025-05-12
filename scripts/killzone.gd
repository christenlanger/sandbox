extends Area2D

signal kill_triggered


func _on_body_entered(body: Node2D) -> void:
	body.get_node("CollisionShape2D").queue_free()
	kill_triggered.emit()
