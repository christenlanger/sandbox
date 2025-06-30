extends Node2D

@export var _stage_container: Node2D
@export var _ui: UI
@export var _pause_menu: PauseMenu
@export var _bgm_manager: AudioStreamPlayer

var _current_stage: Stage
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
	_current_stage.stage_end.connect(unload_stage, ConnectFlags.CONNECT_DEFERRED)
	_current_stage.stage_reset.connect(reset_stage, ConnectFlags.CONNECT_DEFERRED)
	_current_stage.enable_restart.connect(enable_restart)
	_current_stage.set_bgm.connect(set_bgm)
	
	# Add the loaded stage to the game
	_stage_container.add_child(_current_stage)


# Temp unload stage
func unload_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()
	
	# Disable resetting
	_ui.enabled = false
	
	# TODO: Stage select or results screen whatever. A signal to go to those would be preferred as well.
	_stage_ct += 1
	load_stage(_stage_ct)


# Temp reset stage
func reset_stage() -> void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()
	
	load_stage(_stage_ct)


# Toggle restarting
func enable_restart(enabled: bool) -> void:
	_ui.enabled = enabled


# Play BGM
func set_bgm(bgm_name: String) -> void:
	if bgm_name == "":
		_bgm_manager.stop()
	else:
		_bgm_manager.set("parameters/switch_to_clip", bgm_name)
		_bgm_manager.play()


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
		_ui.add_child(_settings_menu)
