extends Node2D

@onready var _state_chart_debugger: MarginContainer = $StateChartDebugger
@onready var _state_chart: StateChart = %Player/StateChart
@onready var _timer: Timer = %Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Delay before enabling player movement. Ideally this comes after a loading screen
	_timer.wait_time = 0.5
	_timer.timeout.connect(_stage_loaded)
	_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Call stage load events
func _stage_loaded() -> void:
	_timer.stop()
	_state_chart.send_event("enable_move")

# Call stage clear event
func _on_clear_zone_body_entered(body: Node2D) -> void:
	$Rick.visible = true
	$Labels/Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Labels/Label.text = "You did it!"
