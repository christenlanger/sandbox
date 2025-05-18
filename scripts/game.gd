extends Node2D

@onready var _stage_container: Node2D = $StageContainer

var _current_stage: Node2D
var _stage_ct := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the stage and call a function afterwards
	load_stage(_stage_ct)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Call common events everytime a stage loads.
func _on_stage_loaded() -> void:
	pass


# Load the stage
func load_stage(index: int) -> void:
	# Instantiate the stage and connect to signals
	_current_stage = load(Global.stages[index]).instantiate()
	_current_stage.ready.connect(_on_stage_loaded)
	_current_stage.stage_end.connect(unload_stage)
	_current_stage.stage_reset.connect(reset_stage)
	
	# Check if settings menu exists in the stage
	if _current_stage.has_node("%PauseMenu"):
		var settings_menu := _current_stage.get_node("%PauseMenu/SettingsMenu")
		settings_menu.settings_updated.connect(_on_receive_settings_update)
	
	# Add the loaded stage to the game
	_stage_container.add_child(_current_stage)


# Temp unload stage
func unload_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()
	
	_stage_ct += 1
	load_stage(_stage_ct)


# Temp reset stage
func reset_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()

	load_stage(_stage_ct)


# Process global shortcuts
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# Process settings
func _on_receive_settings_update(options: Dictionary) -> void:
	Config.apply_config_changes(options)
