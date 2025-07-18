extends OptionsUI

@export var title: String

@onready var _state_chart: StateChart = $StateChart

signal confirm(option: bool)

# Change some properties
func _ready() -> void:
	%Title.text = title
	super()


# Handle input on open
func _on_open_state_input(event: InputEvent) -> void:
	handle_input(event)


# Handle options
func _on_option_selected(option: int) -> void:
	# Close this dialog box
	confirm.emit(not option)
