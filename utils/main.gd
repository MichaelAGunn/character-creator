extends Node3D

const SAVE_PATH: String = "user://character_appearance.tres"

@onready var creator_ui: Control = $CreatorUI
@onready var player: Node3D = $Player
@onready var main_menu = $MainMenu
@onready var photo_gallery = $PhotoGallery
@onready var photo_effects = $PhotoEffects

var never_ui: bool = true
var never_mm: bool = true
var never_gallery: bool = true
var appearance: CharacterAppearance

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
					main_menu.resume_button.pressed.connect(_on_resume_pressed)
					main_menu.load_button.pressed.connect(_on_load_pressed)
					main_menu.save_button.pressed.connect(_on_save_pressed)
					main_menu.gallery_button.pressed.connect(_on_gallery_pressed)
					main_menu.exit_button.pressed.connect(_on_exit_pressed)
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
							creator_ui.save_button.pressed.connect(_on_submit_pressed)
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


func _on_submit_pressed() -> void:
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


func apply_appearance() -> void:
	# TODO: Get the whole file to load!
	creator_ui.apply_appearance(appearance)
	for e in [player, creator_ui]:
		e.body.get_active_material(0).set_shader_parameter("albedo_color", appearance.skin_color)
		e.body.set_blend_shape_value(0, appearance.head_size)
		for i in e.eyes:
			if i != null:
				i.hide()
		e.current_eyes_index = appearance.eye_choice
		creator_ui.change_accessory(0, e.eyes, e.current_eyes_index, e.total_eyes, appearance.eye_color, creator_ui.eyes_label, appearance.pupil_color)
		for h in e.hats:
			if h != null:
				h.hide()
		e.current_hat_index = appearance.hat_choice
		creator_ui.change_accessory(0, e.hats, e.current_hat_index, e.total_hats, appearance.hat_color, creator_ui.hats_label)
		for s in e.shirts:
			if s != null:
				s.hide()
		e.current_shirt_index = appearance.shirt_choice
		creator_ui.change_accessory(0, e.shirts, e.current_shirt_index, e.total_shirts, appearance.shirt_color, creator_ui.shirts_label)
		for p in e.pants:
			if p != null:
				p.hide()
		e.current_pants_index = appearance.pants_choice
		creator_ui.change_accessory(0, e.pants, e.current_pants_index, e.total_pants, appearance.pants_color, creator_ui.pants_label)
		e.body.set_blend_shape_value(1, appearance.hand_size)
		for r in e.rings:
			if r != null:
				r.hide()
		e.current_ring_index = appearance.ring_choice
		creator_ui.change_accessory(0, e.rings, e.current_ring_index, e.total_rings, appearance.ring_color, creator_ui.rings_label, appearance.gem_color)
		for n in e.earrings:
			if n != null:
				n.hide()
		e.current_earring_index = appearance.earring_choice
		creator_ui.change_accessory(0, e.earrings, e.current_earring_index, e.total_earrings, appearance.earring_color, creator_ui.earrings_label)
		e.body.set_blend_shape_value(2, appearance.foot_size)
		for s in e.shoes:
			if s != null:
				s.hide()
		e.current_shoes_index = appearance.shoe_choice
		creator_ui.change_accessory(0, e.shoes, e.current_shoes_index, e.total_shoes, appearance.shoe_color, creator_ui.shoes_label)
	
	# Set UI parameters to match loaded appearance
	creator_ui.fully_revert_ui()


func _on_resume_pressed() -> void:
	toggle_main_menu()


func _on_load_pressed() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		appearance = ResourceLoader.load(SAVE_PATH) as CharacterAppearance
		if appearance:
			apply_appearance()
			print("Character appearance loaded.")
			return
	
	# No save file found, create a new one with defaults
	appearance = CharacterAppearance.new()
	print("No saved character found – using defaults.")
	apply_appearance()


func _on_save_pressed() -> void:
	# Make sure the resource exists
	if appearance == null:
		appearance = CharacterAppearance.new()
	
	# Update the resource with the current values from your UI / character
	appearance.skin_color = creator_ui.skin_color_picker_button.get_picker().color
	appearance.head_size = creator_ui.head_h_slider.value
	appearance.eye_choice = creator_ui.current_eyes_index
	appearance.eye_color = creator_ui.eye_color_picker_button.get_picker().color
	appearance.pupil_color = creator_ui.pupil_color_picker_button.get_picker().color
	appearance.hat_choice = creator_ui.current_hat_index
	appearance.hat_color = creator_ui.hat_color_picker_button.get_picker().color
	appearance.shirt_choice = creator_ui.current_shirt_index
	appearance.shirt_color = creator_ui.shirt_color_picker_button.get_picker().color
	appearance.pants_choice = creator_ui.current_pants_index
	appearance.pants_color = creator_ui.pants_color_picker_button.get_picker().color
	appearance.hand_size = creator_ui.hands_h_slider.value
	appearance.ring_choice = creator_ui.current_ring_index
	appearance.ring_color = creator_ui.ring_color_picker_button.get_picker().color
	appearance.gem_color = creator_ui.gem_color_picker_button.get_picker().color
	appearance.earring_choice = creator_ui.current_earring_index
	appearance.earring_color = creator_ui.earring_color_picker_button.get_picker().color
	appearance.foot_size = creator_ui.feet_h_slider.value
	appearance.shoe_choice = creator_ui.current_shoes_index
	appearance.shoe_color = creator_ui.shoes_color_picker_button.get_picker().color
	
	# Save if possible
	var error := ResourceSaver.save(appearance, SAVE_PATH)
	if error == OK:
		print("Character appearance saved.")
	else:
		push_error("Failed to save character appearance. Error: %s" % error)


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
