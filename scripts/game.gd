extends Node2D

@onready var _stage_container: Node2D = $StageContainer

var _current_stage: Node2D

# Stages
var _stages := [
	"res://scenes/stages/stage_1.tscn",
	"res://scenes/stages/stage_2.tscn",
]

var _stage_ct := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the stage and call a function afterwards
	_load_stage(_stage_ct)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Call common events everytime a stage loads.
func _on_stage_loaded() -> void:
	pass


func _load_stage(index: int) -> void:
	_current_stage = load(_stages[index]).instantiate()
	_current_stage.ready.connect(_on_stage_loaded)
	
	_current_stage.stage_end.connect(_unload_stage)
	_current_stage.stage_reset.connect(_reset_stage)
	_stage_container.add_child(_current_stage)


# Temp unload stage
func _unload_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()
	
	_stage_ct += 1
	_load_stage(_stage_ct)


# Temp reset stage
func _reset_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()

	_load_stage(_stage_ct)


# Process global shortcuts
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
