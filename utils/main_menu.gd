extends Control

@onready var resume = $VBoxContainer/Resume
@onready var mode = $VBoxContainer/Mode
@onready var load = $VBoxContainer/Load
@onready var credits = $VBoxContainer/Credits
@onready var exit = $VBoxContainer/Exit

func _ready() -> void:
	visible = false
	load.pressed.connect(_on_load_pressed)
	credits.pressed.connect(_on_credits_pressed)


func _on_load_pressed() -> void:
	pass


func _on_credits_pressed() -> void:
	pass
