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
	load_button.pressed.connect(_on_load_pressed)
	#save_button.pressed.connect(_on_save_pressed)
	credits_button.pressed.connect(_on_credits_pressed)


func _on_load_pressed() -> void:
	# TODO: Load the saved outfit to game
	pass


#func _on_save_pressed() -> void:
	## TODO: Save the current outfit to file
	## Make sure the resource exists
	#if appearance == null:
		#appearance = CharacterAppearance.new()
	## Update the resource with the current values from your UI / character
	#appearance.skin_color = player.skin
	#appearance.hair_color = hair_color_picker.color
	#appearance.skin_tone = skin_color_picker.color
	#appearance.eye_color = eye_color_picker.color
	#appearance.outfit = current_outfit
	#var error := ResourceSaver.save(appearance, SAVE_PATH)
	#if error == OK:
		#print("Character appearance saved.")
	#else:
		#push_error("Failed to save character appearance. Error: %s" % error)


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
