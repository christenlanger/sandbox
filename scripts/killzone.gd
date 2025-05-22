extends Area2D

signal kill_triggered

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		kill_triggered.emit()
