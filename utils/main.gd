extends Node3D

@onready var creator_ui: Control = $CreatorUI
@onready var player: Node3D = $Player
@onready var main_menu = $MainMenu

var never_ui: bool = true
var never_mm: bool = true
var photo_mode: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_process_input(true)
	set_process_unhandled_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Open and close UI; first time connects buttons
		if Input.is_action_just_pressed("pause"):
			if never_ui:
				creator_ui.save_button.pressed.connect(_on_save_pressed)
				creator_ui.cancel_button.pressed.connect(_on_cancel_pressed)
				never_ui = false
			toggle_ui()
		if Input.is_action_just_pressed("main"):
			if never_mm:
				main_menu.resume.pressed.connect(_on_resume_pressed)
				main_menu.mode.pressed.connect(_on_mode_pressed)
				main_menu.exit.pressed.connect(_on_exit_pressed)
				never_mm = false
			toggle_main_menu()


func toggle_ui() -> void:
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
	toggle_ui()


func _on_cancel_pressed() -> void:
	toggle_ui()


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


func _on_mode_pressed() -> void:
	photo_mode = !photo_mode
	if photo_mode:
		pass
	else:
		pass


func _on_exit_pressed() -> void:
	get_tree().quit()
