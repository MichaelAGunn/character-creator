extends Control

@onready var button_container: VBoxContainer = $ColorRect/VBoxContainer
@onready var credits_container: MarginContainer = $ColorRect/CreditsMargin
@onready var credit_reel: Label = $ColorRect/CreditsMargin/ColorRect/CreditReel
@onready var resume_button: Button = $ColorRect/VBoxContainer/Resume
@onready var load_button: Button = $ColorRect/VBoxContainer/Load
@onready var save_button: Button = $ColorRect/VBoxContainer/Save
@onready var gallery_button: Button = $ColorRect/VBoxContainer/Gallery
@onready var credits_button: Button = $ColorRect/VBoxContainer/Credits
@onready var exit_button: Button = $ColorRect/VBoxContainer/Exit

var credits_playing: bool = false

func _ready() -> void:
	hide()
	credits_container.modulate.a = 0.0
	credit_reel.modulate.a = 0.0
	credits_button.pressed.connect(_on_credits_pressed)


func _on_credits_pressed() -> void:
	credits_playing = true
	button_container.hide()
	
	var credit_in_tween = create_tween()
	credit_in_tween.tween_property(credits_container, "modulate:a", 1.0, 1.0)
	var reel_in_tween = create_tween()
	reel_in_tween.tween_property(credit_reel, "modulate:a", 1.0, 1.0)
	await reel_in_tween.finished
	credit_in_tween.kill()
	reel_in_tween.kill()
	await get_tree().create_timer(3.0).timeout
	
	var credit_out_tween = create_tween()
	credit_out_tween.tween_property(credits_container, "modulate:a", 0.0, 1.0)
	var reel_out_tween = create_tween()
	reel_out_tween.tween_property(credit_reel, "modulate:a", 0.0, 1.0)
	await reel_out_tween.finished
	credit_out_tween.kill()
	reel_out_tween.kill()
	
	button_container.show()
	credits_playing = false
