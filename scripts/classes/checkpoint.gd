class_name Checkpoint

extends Area2D

signal set_spawn_point(new_spawn_point: Vector2)

var _collision_shape_2d: CollisionShape2D
var _marker_2d: Marker2D


func _ready() -> void:
	# Find child nodes to assign
	for node in get_children():
		if node is CollisionShape2D:
			_collision_shape_2d = node
		elif node is Marker2D:
			_marker_2d =  node

	if _collision_shape_2d:
		body_entered.connect(_on_hit_checkpoint)


# Free the collision node
# TODO: possibly provide a way to disable collision node
#		so we can re-enable it later
func _on_hit_checkpoint(_body: Node) -> void:
	var new_pos := _marker_2d.global_position if _marker_2d else global_position
	_collision_shape_2d.queue_free()
	
	set_spawn_point.emit(new_pos)
