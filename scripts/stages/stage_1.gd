extends Stage

@onready var _state_chart_debugger: MarginContainer = $StateChartDebugger
@onready var _state_chart: StateChart = %Player/StateChart
@onready var _timer: Timer = %Timer
@onready var player: CharacterBody2D = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# Set initial spawn point
	_spawn_point = player.position
	
	# Delay before enabling player movement. Ideally this comes after a loading screen
	_timer.wait_time = 0.5
	_timer.timeout.connect(_stage_loaded)
	_timer.start()


# Call stage load events
func _stage_loaded() -> void:
	_timer.stop()
	
	_state_chart.send_event("enable_move")


# Call stage clear event
func _on_clear_zone_body_entered(body: Node2D) -> void:
	for clearzone in get_tree().get_nodes_in_group("clearzones"):
		clearzone.get_node("CollisionShape2D").queue_free()
	%Rick.visible = true
	$Labels/Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Labels/Label.text = "You did it!"
	$Labels/Label4.text = "Press Up on the door\nto go to next stage"
	for stage_door in get_tree().get_nodes_in_group("stage_doors"):
		stage_door.visible = true
		stage_door.get_node("CollisionShape2D").set_deferred("disabled", false)


# End of stage signal emit
func _input(event: InputEvent) -> void:
	if _can_clear and event.is_action_pressed(Global.action_list[Global.ActionList.UP]):
		stage_end.emit()


# Enable door to next stage
func _on_to_next_stage_body_entered(body: Node2D) -> void:
	_can_clear = true


func _on_to_next_stage_body_exited(body: Node2D) -> void:
	_can_clear = false


func _on_pause_menu_pause() -> void:
	%PauseMenu.visible = true
	get_tree().paused = true


func _on_pause_menu_resume() -> void:
	%PauseMenu.visible = false
	get_tree().paused = false


func _on_player_debug_text(text: String) -> void:
	$UI/DebugText.text = text
