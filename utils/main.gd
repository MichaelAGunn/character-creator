extends Node3D

@onready var creator_ui: Control = $CreatorUI
@onready var player: Node3D = $Player

var never_ui: bool = true

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
