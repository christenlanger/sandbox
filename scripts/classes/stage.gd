class_name Stage

extends Node2D

signal stage_reset
signal stage_end

var _can_clear := false

var _spawn_point := Vector2(0.0, 0.0)

func _ready() -> void:
	for killzone in get_tree().get_nodes_in_group("killzones"):
		killzone.kill_triggered.connect(_do_stage_reset)
	
	for stage_ui in get_tree().get_nodes_in_group("stage_ui"):
		stage_ui.restart_triggered.connect(_do_stage_reset)


func _do_stage_reset() -> void:
	stage_reset.emit()
