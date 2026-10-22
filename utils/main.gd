extends Node3D

@onready var creator_ui: Control = $CreatorUI
@onready var player: Node3D = $Player
@onready var main_menu = $MainMenu
@onready var photo_gallery = $PhotoGallery
@onready var photo_effects = $PhotoEffects

var never_ui: bool = true
var never_mm: bool = true
var never_gallery: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_process_input(true)
	set_process_unhandled_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Open and close UI; first time connects buttons
		if Input.is_action_just_pressed("main"):
			if creator_ui.camera.current:
				if never_mm:
					main_menu.resume_btn.pressed.connect(_on_resume_pressed)
					main_menu.gallery_btn.pressed.connect(_on_gallery_pressed)
					main_menu.exit_btn.pressed.connect(_on_exit_pressed)
					never_mm = false
				if photo_gallery.gallery_active:
					if photo_gallery.full_view.visible:
						photo_gallery._close_full_view()
					else:
						photo_gallery.hide()
						photo_gallery.gallery_active = false
				else:
					if photo_effects.photo_mode:
						photo_effects.toggle_photo_mode()
					toggle_main_menu()
		if photo_gallery.gallery_active == false:
			if Input.is_action_just_pressed("creator"):
				if main_menu.visible == false:
					if photo_effects.photo_mode == false:
						if never_ui:
							creator_ui.save_button.pressed.connect(_on_save_pressed)
							creator_ui.cancel_button.pressed.connect(_on_cancel_pressed)
							never_ui = false
						toggle_creator()
			if Input.is_action_just_pressed("photo_mode"):
				if main_menu.visible == false:
					if creator_ui.visible == false:
						photo_effects.toggle_photo_mode()
			if Input.is_action_just_pressed("take_photo"):
				if photo_effects.photo_mode:
					PhotoManager.take_photo()


func toggle_creator() -> void:
	creator_ui.visible = !creator_ui.visible
	creator_ui.body.visible = !creator_ui.body.visible
	player.visible = !player.visible
	if player.camera.current:
		creator_ui.camera.make_current()
		player.camera.clear_current()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		AudioManager.ui.set_stream(AudioManager.CYCLE)
	elif creator_ui.camera.current:
		creator_ui.fully_revert_ui()
		creator_ui._on_cancel_pressed()
		player.camera.clear_current()
		player.camera.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_save_pressed() -> void:
	toggle_creator()


func _on_cancel_pressed() -> void:
	toggle_creator()


func toggle_main_menu() -> void:
	main_menu.visible = !main_menu.visible
	AudioManager.ui.set_stream(AudioManager.MAIN)
	if main_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		AudioManager.ui.pitch_scale = 0.9
	AudioManager.ui.play()


func _on_resume_pressed() -> void:
	toggle_main_menu()


func _on_gallery_pressed() -> void:
	photo_effects.photo_mode = !photo_effects.photo_mode
	main_menu.visible = !main_menu.visible
	photo_gallery.visible = !photo_gallery.visible
	photo_gallery.gallery_active = true
	AudioManager.ui.play()
	if never_gallery:
		photo_gallery.back_button.pressed.connect(_on_leave_gallery)
		never_gallery = false


func _on_leave_gallery() -> void:
	toggle_main_menu()


func _on_exit_pressed() -> void:
	get_tree().quit()
