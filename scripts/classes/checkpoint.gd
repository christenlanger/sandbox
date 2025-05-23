class_name Checkpoint

extends Area2D

signal set_spawn_point(new_spawn_point: Vector2)
signal checkpoint_hit(checkpoint_name: String)

@export var _collision_shape_2d: CollisionShape2D
@export var _marker_2d: Marker2D
@export var _set_spawn_point: bool = true ## Set player spawn point when hitting checkpoint
@export var _checkpoint_name: String ## Name of the checkpoint for use with triggers


func _ready() -> void:
	if _collision_shape_2d:
		body_entered.connect(_on_hit_checkpoint)

# Free the collision node
# TODO: possibly provide a way to disable collision node
#		so we can re-enable it later
func _on_hit_checkpoint(_body: Node) -> void:
	var new_pos := _marker_2d.global_position if _marker_2d else global_position
	_collision_shape_2d.queue_free()
	
	set_spawn_point.emit(new_pos)
	checkpoint_hit.emit(_checkpoint_name)
