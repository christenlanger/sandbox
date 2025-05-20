extends PanelContainer

signal confirm
signal cancel
signal click_cancel

@onready var title_text: Label = %TitleText
@onready var message_text: Label = %MessageText
@onready var button_ok: Button = %ButtonOK
@onready var button_cancel: Button = %ButtonCancel
@onready var button_container: HBoxContainer = %ButtonContainer


var title : String :
	get:
		return title_text.text
	set(value):
		title_text.text = value

var message : String :
	get:
		return message_text.text
	set(value):
		message_text.text = value


func _ready() -> void:
	button_ok.pressed.connect(_on_button_ok_pressed)
	button_cancel.pressed.connect(_on_button_cancel_pressed)


func _on_button_ok_pressed() -> void:
	confirm.emit()


func _on_button_cancel_pressed() -> void:
	click_cancel.emit() 


func disable_buttons() -> void:
	button_container.set_deferred("visible", false)


func close() -> void:
	cancel.emit()
