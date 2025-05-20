extends Node2D

@onready var _stage_container: Node2D = $StageContainer

var _current_stage: Node2D
var _pause_menu: Control
var _settings_menu: Control
var _stage_ct := 0

# Game flags
enum GameFlags {
	IS_PAUSABLE,
}

var game_flags = {
	GameFlags.IS_PAUSABLE: true,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the stage and call a function afterwards
	load_stage(_stage_ct)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Call common events everytime a stage loads.
func _on_stage_loaded() -> void:
	print("Stage loaded")


# Load the stage
func load_stage(index: int) -> void:
	# Instantiate the stage and connect to signals
	_current_stage = load(Global.STAGES[index]).instantiate()
	_current_stage.ready.connect(_on_stage_loaded)
	_current_stage.stage_end.connect(unload_stage)
	_current_stage.stage_reset.connect(reset_stage)
	
	# Connect to pause menu signals
	if _current_stage.has_node("%PauseMenu"):
		_pause_menu = _current_stage.get_node("%PauseMenu")
		_pause_menu.open_settings.connect(open_settings)
	
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


# Handle inputs
func _input(event: InputEvent) -> void:
	# Pause game
	if event.is_action_pressed("ui_toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# Process settings
func _on_receive_settings(options: Dictionary) -> void:
	Config.accept_config_changes(options)


# Open settings menu
func open_settings() -> void:
	_settings_menu = load(Global.SETTINGS_SCENE).instantiate()

	if is_instance_valid(_settings_menu):
		_settings_menu.send_settings.connect(_on_receive_settings)
		_settings_menu.closed.connect(func():
			_settings_menu.queue_free.call_deferred()
		)
		# If the pause menu is active, connect settings close signal to it as well
		if is_instance_valid(_pause_menu):
			_settings_menu.closed.connect(_pause_menu.close_settings)
		_current_stage.get_node("UI").add_child(_settings_menu)
