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

## Paths
var _scene_path_root := "res://scenes/"
var scene_paths := {
	ScenePaths.ROOT:	_scene_path_root,
	ScenePaths.STAGES:	_scene_path_root + "stages/",
	ScenePaths.UI:		_scene_path_root + "ui/",
}

var _script_path_root = "res://scripts/"
var script_paths := {
	ScriptPaths.ROOT:		_script_path_root,
	ScriptPaths.CLASSES:	_script_path_root + "classes/",
	ScriptPaths.STAGES:		_script_path_root + "stages/",
	ScriptPaths.UI:			_script_path_root + "ui/",
}

## Stages
var stages := [
	"res://scenes/stages/stage_1.tscn",
	"res://scenes/stages/stage_2.tscn",
]

## Label styles
var label_settings = {}

func _ready() -> void:
	label_settings = {
		LabelPresets.DEFAULT: load("res://assets/ui_label_option.tres"),
		LabelPresets.SELECTED: load("res://assets/ui_label_option_selected.tres"),
	}
