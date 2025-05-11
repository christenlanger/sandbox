extends Node2D

@onready var _stage_container: Node2D = $StageContainer

var _current_stage: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the stage and call a function afterwards
	var _current_stage = preload("res://scenes/stage_1.tscn").instantiate()
	
	_current_stage.ready.connect(_on_stage_loaded)
	_stage_container.add_child(_current_stage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Call common events everytime a stage loads.
func _on_stage_loaded() -> void:
	pass
