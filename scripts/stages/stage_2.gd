extends Stage

@onready var _state_chart: StateChart = %Player/StateChart
@onready var _timer: Timer = %Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# Delay before enabling player movement. Ideally this comes after a loading screen
	_timer.wait_time = 0.5
	_timer.timeout.connect(_stage_loaded)
	_timer.start()


# Call stage load events
func _stage_loaded() -> void:
	_timer.stop()
	_state_chart.send_event("enable_move")
