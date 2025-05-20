extends Node

## Enums
enum ScenePaths {
	ROOT, STAGES, UI
}

enum ScriptPaths {
	ROOT, CLASSES, STAGES, UI
}

enum LabelPresets {
	DEFAULT, SELECTED
}

enum StyleBoxPresets {
	HIGHLIGHTED
}

enum ActionList {
	UP, DOWN, LEFT, RIGHT, JUMP, DASH, RESTART, PAUSE
}

## Paths
const _scene_path_root := "res://scenes/"
const scene_paths := {
	ScenePaths.ROOT:	_scene_path_root,
	ScenePaths.STAGES:	_scene_path_root + "stages/",
	ScenePaths.UI:		_scene_path_root + "ui/",
}

const _script_path_root = "res://scripts/"
const script_paths := {
	ScriptPaths.ROOT:		_script_path_root,
	ScriptPaths.CLASSES:	_script_path_root + "classes/",
	ScriptPaths.STAGES:		_script_path_root + "stages/",
	ScriptPaths.UI:			_script_path_root + "ui/",
}

## Stages
const stages := [
	"res://scenes/stages/stage_1.tscn",
	"res://scenes/stages/stage_2.tscn",
]

## Resource styles
var label_settings = {}
var stylebox_settings = {}

func _ready() -> void:
	label_settings = {
		LabelPresets.DEFAULT: load("res://assets/ui_label_option.tres"),
		LabelPresets.SELECTED: load("res://assets/ui_label_option_selected.tres"),
	}
	
	stylebox_settings = {
		StyleBoxPresets.HIGHLIGHTED: load("res://assets/style_box_flat_highlighted.tres")
	}

## Actions
const action_list = {
	ActionList.JUMP: "jump",
	ActionList.DASH: "dash",
	ActionList.UP: "up",
	ActionList.DOWN: "crouch",
	ActionList.LEFT: "move_left",
	ActionList.RIGHT: "move_right",
	ActionList.RESTART: "restart",
	ActionList.PAUSE: "pause",
}
