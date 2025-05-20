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
const _SCENE_PATH_ROOT := "res://scenes/"
const SCENE_PATHS := {
	ScenePaths.ROOT:	_SCENE_PATH_ROOT,
	ScenePaths.STAGES:	_SCENE_PATH_ROOT + "stages/",
	ScenePaths.UI:		_SCENE_PATH_ROOT + "ui/",
}

const _SCRIPT_PATH_ROOT = "res://scripts/"
const SCRIPT_PATHS := {
	ScriptPaths.ROOT:		_SCRIPT_PATH_ROOT,
	ScriptPaths.CLASSES:	_SCRIPT_PATH_ROOT + "classes/",
	ScriptPaths.STAGES:		_SCRIPT_PATH_ROOT + "stages/",
	ScriptPaths.UI:			_SCRIPT_PATH_ROOT + "ui/",
}

# Important scenes
const SETTINGS_SCENE = SCENE_PATHS[ScenePaths.UI] + "settings_menu.tscn"

## Stages
const STAGES := [
	SCENE_PATHS[ScenePaths.STAGES] + "stage_1.tscn",
	SCENE_PATHS[ScenePaths.STAGES] + "stage_2.tscn",
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
const ACTION_LIST = {
	ActionList.JUMP: "jump",
	ActionList.DASH: "dash",
	ActionList.UP: "up",
	ActionList.DOWN: "crouch",
	ActionList.LEFT: "move_left",
	ActionList.RIGHT: "move_right",
	ActionList.RESTART: "restart",
	ActionList.PAUSE: "pause",
}
