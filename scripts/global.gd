extends Node

enum LabelPresets {
	DEFAULT,
	SELECTED,
}

var label_settings = {}

# Stages
var stages := [
	"res://scenes/stages/stage_1.tscn",
	"res://scenes/stages/stage_2.tscn",
]


func _ready() -> void:
	label_settings = {
		LabelPresets.DEFAULT: load("res://assets/ui_label_option.tres"),
		LabelPresets.SELECTED: load("res://assets/ui_label_option_selected.tres"),
	}
