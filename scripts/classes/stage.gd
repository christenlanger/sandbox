class_name Stage

extends Node2D

signal stage_reset
signal stage_end

var _can_clear := false

var _player: CharacterBody2D
var _spawn_point := Vector2(0.0, 0.0)


func _ready() -> void:
	for killzone in get_tree().get_nodes_in_group("killzones"):
		killzone.kill_triggered.connect(_on_kill_triggered)
	
	if has_node("%Player"):
		_player = get_node("%Player")
		_player.teleport_to_spawn.connect(_teleport_to_spawn)
		_spawn_point = _player.global_position
	
	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		checkpoint.set_spawn_point.connect(_on_set_spawn_point)


func _do_stage_reset() -> void:
	stage_reset.emit()


func _on_kill_triggered() -> void:
	if _player:
		_player.kill_player()


func _teleport_to_spawn() -> void:
	print("Teleport to ", _spawn_point)
	_player.global_position = _spawn_point


func _on_set_spawn_point(new_pos: Vector2):
	_spawn_point = new_pos
	print("New spawn point set ", _spawn_point)
