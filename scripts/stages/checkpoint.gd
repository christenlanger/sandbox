extends Area2D

func set_new_spawn(clear_collision: bool = true) -> Vector2:
	if clear_collision and has_node("CollisionShape2D"):
		get_node("CollisionShape2D").queue_free()

	var spawn_point := position
	if has_node("Marker2D"):
		spawn_point = get_node("Marker2D").position
	
	return spawn_point
