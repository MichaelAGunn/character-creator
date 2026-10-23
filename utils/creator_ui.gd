extends Control

const TOON = preload("uid://btrikqauyyvs2")
const OUTLINE = preload("uid://dxfb53kwyrd3a")

@export var player: Player

# Subviewport Assets
@onready var skeleton: Skeleton3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/elokido/Rig/Skeleton3D
@onready var body: MeshInstance3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/elokido/Rig/Skeleton3D/Mesh
@onready var sub_viewport: SubViewport = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport
@onready var camera: Camera3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/Camera3D

# Color Picker Buttons
@onready var skin_color_picker_button: ColorPickerButton = %SkinColorPickerButton
@onready var eye_color_picker_button: ColorPickerButton = %EyeColorPickerButton
@onready var pupil_color_picker_button: ColorPickerButton = %PupilColorPickerButton
@onready var hat_color_picker_button: ColorPickerButton = %HatColorPickerButton
@onready var shirt_color_picker_button: ColorPickerButton = %ShirtColorPickerButton
@onready var pants_color_picker_button: ColorPickerButton = %PantsColorPickerButton
@onready var ring_color_picker_button: ColorPickerButton = %RingColorPickerButton
@onready var gem_color_picker_button: ColorPickerButton = %GemColorPickerButton
@onready var earring_color_picker_button: ColorPickerButton = %EarringColorPickerButton
@onready var shoes_color_picker_button: ColorPickerButton = %ShoesColorPickerButton
@onready var picker_buttons: Array[ColorPickerButton] = [
	skin_color_picker_button,
	eye_color_picker_button,
	pupil_color_picker_button,
	hat_color_picker_button,
	shirt_color_picker_button,
	pants_color_picker_button,
	ring_color_picker_button,
	gem_color_picker_button,
	earring_color_picker_button,
	shoes_color_picker_button,
]

# Sliders for Blend Keys
@onready var head_h_slider: HSlider = %HeadHSlider
@onready var hands_h_slider: HSlider = %HandsHSlider
@onready var feet_h_slider: HSlider = %FeetHSlider
@onready var h_sliders: Array[HSlider] = [
	head_h_slider,
	hands_h_slider,
	feet_h_slider
]

# Lists of Accessories
@onready var eyes_prev: Button = %EyesPrev
@onready var eyes_label: Label = %EyesLabel
@onready var eyes_next: Button = %EyesNext
@onready var hats_prev: Button = %HatsPrev
@onready var hats_label: Label = %HatsLabel
@onready var hats_next: Button = %HatsNext
@onready var shirts_prev: Button = %ShirtsPrev
@onready var shirts_label: Label = %ShirtsLabel
@onready var shirts_next: Button = %ShirtsNext
@onready var pants_prev: Button = %PantsPrev
@onready var pants_label: Label = %PantsLabel
@onready var pants_next: Button = %PantsNext
@onready var rings_prev: Button = %RingsPrev
@onready var rings_label: Label = %RingsLabel
@onready var rings_next: Button = %RingsNext
@onready var earrings_prev: Button = %EarringsPrev
@onready var earrings_label: Label = %EarringsLabel
@onready var earrings_next: Button = %EarringsNext
@onready var shoes_prev: Button = %ShoesPrev
@onready var shoes_label: Label = %ShoesLabel
@onready var shoes_next: Button = %ShoesNext
@onready var eyes: Array[MeshInstance3D] = [null]
@onready var mouths: Array[MeshInstance3D] = [null]
@onready var tails: Array[MeshInstance3D] = [null]
@onready var hats: Array[MeshInstance3D] = [null]
@onready var shirts: Array[MeshInstance3D] = [null]
@onready var pants: Array[MeshInstance3D] = [null]
@onready var rings: Array[MeshInstance3D] = [null]
@onready var earrings: Array[MeshInstance3D] = [null]
@onready var shoes: Array[MeshInstance3D] = [null]
@onready var accessory_swap_buttons: Array[Button] = [
	eyes_prev, eyes_next,
	hats_prev, hats_next,
	shirts_prev, shirts_next,
	pants_prev, pants_next,
	rings_prev, rings_next,
	earrings_prev, earrings_next,
	shoes_prev, shoes_next
]

# Buttons to Leave UI
@onready var save_button: Button = %SaveButton
@onready var cancel_button: Button = %CancelButton

var materials_loaded: bool = false

var total_eyes: int
var total_hats: int
var total_shirts: int
var total_pants: int
var total_rings: int
var total_earrings: int
var total_shoes: int

var current_eyes_index: int = 0
var current_hat_index: int = 0
var current_shirt_index: int = 0
var current_pants_index: int = 0
var current_ring_index: int = 0
var current_earring_index: int = 0
var current_shoes_index: int = 0

signal saved

func _ready() -> void:
	visible = false
	body.visible = false
	
	# Initialize shaders
	var shader := ShaderMaterial.new()
	shader.shader = TOON
	shader.set_shader_parameter("use_rim", false)
	shader.set_shader_parameter("use_stepped", true)
	shader.set_shader_parameter("steps", 2.0)
	shader.set_shader_parameter("step_smoothness", 0.0)
	var next_shader := ShaderMaterial.new()
	next_shader.shader = OUTLINE
	shader.next_pass = next_shader
	var specular_shader := shader.duplicate()
	specular_shader.set_shader_parameter("specular", 0.3)
	
	# Connect color picker buttons
	for color_picker_button in picker_buttons:
		color_picker_button.color_changed.connect(_on_color_picked.bind(color_picker_button))
		var color_picker: ColorPicker = color_picker_button.get_picker()
		color_picker.sampler_visible = false
		color_picker.color_modes_visible = false
		color_picker.sliders_visible = false
		color_picker.hex_visible = false
		color_picker.presets_visible = false
	
	# Connect sliders
	for h_slider in h_sliders:
		h_slider.value_changed.connect(_on_slider_changed.bind(h_slider))
	
	# Connect accessory swap buttons
	for button in accessory_swap_buttons:
		button.pressed.connect(_on_accessory_button_pressed.bind(button))
	
	# Connect UI exit buttons
	save_button.pressed.connect(_on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Find all accessories
	for child in skeleton.get_children():
		if child is MeshInstance3D:
			# Sort the accessories
			var category: String = child.name.get_slice("_", 0)
			if child.name != "Mesh":
				child.name = child.name.get_slice("_", 1)
				child.hide()
			# Apply shader material
			for surface in range(child.get_surface_override_material_count()):
				if category in ["Eyes", "Ring", "Earring"]:
					child.set_surface_override_material(surface, specular_shader.duplicate())
				else:
					child.set_surface_override_material(surface, shader.duplicate())
			match category:
				"Eyes": eyes.append(child)
				"Mouth": mouths.append(child)
				"Tail": tails.append(child)
				"Hat": hats.append(child)
				"Shirt": shirts.append(child)
				"Pants": pants.append(child)
				"Ring": rings.append(child)
				"Earring": earrings.append(child)
				"Shoes": shoes.append(child)
	
	# Save totals separately
	total_hats = hats.size()
	total_shirts = shirts.size()
	total_pants = pants.size()
	total_rings = rings.size()
	total_earrings = earrings.size()
	total_shoes = shoes.size()
	total_eyes = eyes.size()


func change_color(new_color: Color, node: MeshInstance3D, slot: int = 0) -> void:
	if node == null:
		return
	
	var old_material = node.get_active_material(slot) as ShaderMaterial
	if old_material:
		var new_material = old_material.duplicate() as ShaderMaterial
		new_material.set_shader_parameter("albedo_color", new_color)
		node.set_surface_override_material(slot, new_material)
	else:
		print("No material found!")


func change_accessory(direction: int, list: Array[MeshInstance3D], index: int, total: int, picker: Color, label: Label, picker2: Color = Color()) -> int:
	var old_acc: MeshInstance3D = list[index]
	if old_acc != null:
		old_acc.hide()
	index = wrap(index + direction, 0, total)
	
	var new_acc: MeshInstance3D = list[index]
	if new_acc != null:
		new_acc.show()
		label.text = new_acc.name
		change_color(picker, new_acc)
		if new_acc.mesh.get_surface_count() > 1:
			change_color(picker2, new_acc, 1)
		if new_acc.get_blend_shape_count() > 0:
			match label:
				hats_label, eyes_label, earrings_label:
					new_acc.set_blend_shape_value(0, body.get_blend_shape_value(0))
				rings_label:
					new_acc.set_blend_shape_value(0, body.get_blend_shape_value(1))
				shoes_label:
					new_acc.set_blend_shape_value(0, body.get_blend_shape_value(2))
	else:
		label.text = "None"
	
	return index


func resize_accessory(list: Array[MeshInstance3D], index: int, value: float) -> void:
	list[index].set_blend_shape_value(0, value)


func resize_whole_body() -> void:
	player.body.set_blend_shape_value(0, head_h_slider.value)
	for hat in player.hats:
		if hat != null:
			if hat.visible:
				hat.set_blend_shape_value(0, head_h_slider.value)
				break
	for eye in player.eyes:
		if eye != null:
			if eye.visible:
				eye.set_blend_shape_value(0, head_h_slider.value)
				break
	for er in player.earrings:
		if er != null:
			if er.visible:
				er.set_blend_shape_value(0, head_h_slider.value)
				break
	player.body.set_blend_shape_value(1, hands_h_slider.value)
	for ring in player.rings:
		if ring != null:
			if ring.visible:
				ring.set_blend_shape_value(0, hands_h_slider.value)
				break
	player.body.set_blend_shape_value(2, feet_h_slider.value)
	for shoe in player.shoes:
		if shoe != null:
			if shoe.visible:
				shoe.set_blend_shape_value(0, feet_h_slider.value)
				break


func revert_color(picker: ColorPickerButton, color: Color, target: MeshInstance3D, slot: int = 0) -> void:
	picker.set_pick_color(color)
	change_color(color, target, slot)


func revert_sizes() -> void:
	head_h_slider.value = player.body.get_blend_shape_value(0)
	hands_h_slider.value = player.body.get_blend_shape_value(1)
	feet_h_slider.value = player.body.get_blend_shape_value(2)


func revert_accessory(list: Array[MeshInstance3D], index: int, _player_list: Array, player_index: int, _picker: ColorPickerButton, label: Label) -> int:
	if index != player_index:
		if list[index] != null:
			list[index].hide()
		index = player_index
		if list[index] != null:
			list[index].show()
			label.text = list[index].name

	return index


func fully_revert_ui() -> void:
	# TODO: Reduce redundancy (which seems impossible atm)
	var revert_to_color: Color = player.body.get_active_material(0).get_shader_parameter("albedo_color")
	revert_color(skin_color_picker_button, revert_to_color, body)
	current_eyes_index = revert_accessory(eyes, current_eyes_index, player.eyes, player.current_eyes_index, eye_color_picker_button, eyes_label)
	if player.eyes[current_eyes_index] != null:
		revert_to_color = player.eyes[player.current_eyes_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(eye_color_picker_button, revert_to_color, eyes[current_eyes_index])
		if player.eyes[current_eyes_index].get_surface_override_material_count() > 1:
			revert_to_color = player.eyes[player.current_eyes_index].get_active_material(1).get_shader_parameter("albedo_color")
			revert_color(pupil_color_picker_button, revert_to_color, eyes[current_eyes_index], 1)
	current_hat_index = revert_accessory(hats, current_hat_index, player.hats, player.current_hat_index, hat_color_picker_button, hats_label)
	if player.hats[current_hat_index] != null:
		revert_to_color = player.hats[player.current_hat_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(hat_color_picker_button, revert_to_color, hats[current_hat_index])
	current_shirt_index = revert_accessory(shirts, current_shirt_index, player.shirts, player.current_shirt_index, shirt_color_picker_button, shirts_label)
	if player.shirts[current_shirt_index] != null:
		revert_to_color = player.shirts[player.current_shirt_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(shirt_color_picker_button, revert_to_color, shirts[current_shirt_index])
	current_pants_index = revert_accessory(pants, current_pants_index, player.pants, player.current_pants_index, pants_color_picker_button, pants_label)
	if player.pants[current_pants_index] != null:
		revert_to_color = player.pants[player.current_pants_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(pants_color_picker_button, revert_to_color, pants[current_pants_index])
	current_ring_index = revert_accessory(rings, current_ring_index, player.rings, player.current_ring_index, ring_color_picker_button, rings_label)
	if player.rings[current_ring_index] != null:
		revert_to_color = player.rings[player.current_ring_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(ring_color_picker_button, revert_to_color, rings[current_ring_index])
		if player.rings[current_ring_index].get_surface_override_material_count() > 1:
			revert_to_color = player.rings[player.current_ring_index].get_active_material(1).get_shader_parameter("albedo_color")
			revert_color(gem_color_picker_button, revert_to_color, rings[current_ring_index])
	current_earring_index = revert_accessory(earrings, current_earring_index, player.earrings, player.current_earring_index, earring_color_picker_button, earrings_label)
	if player.earrings[current_earring_index] != null:
		revert_to_color = player.earrings[player.current_earring_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(earring_color_picker_button, revert_to_color, earrings[current_earring_index])
	current_shoes_index = revert_accessory(shoes, current_shoes_index, player.shoes, player.current_shoes_index, shoes_color_picker_button, shoes_label)
	if player.shoes[current_shoes_index] != null:
		revert_to_color = player.shoes[player.current_shoes_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(shoes_color_picker_button, revert_to_color, shoes[current_shoes_index])
	revert_sizes()


func apply_appearance(appearance) -> void:
	# TODO: make null values disappear (if xyz_choice == 0)
	head_h_slider.value = appearance.head_size
	hands_h_slider.value = appearance.hand_size
	feet_h_slider.value = appearance.foot_size
	skin_color_picker_button.get_picker().color = appearance.skin_color
	if appearance.eye_choice > 0:
		eyes_label.text = eyes[appearance.eye_choice].name
	else:
		eyes_label.text = "None"
	eye_color_picker_button.get_picker().color = appearance.eye_color
	pupil_color_picker_button.get_picker().color = appearance.pupil_color
	if appearance.hat_choice > 0:
		hats_label.text = hats[appearance.hat_choice].name
	else:
		hats_label.text = "None"
	hat_color_picker_button.get_picker().color = appearance.hat_color
	if appearance.shirt_choice > 0:
		shirts_label.text = shirts[appearance.shirt_choice].name
	else:
		shirts_label.text =  "None"
	shirt_color_picker_button.get_picker().color = appearance.shirt_color
	if appearance.pants_choice > 0:
		pants_label.text = pants[appearance.pants_choice].name
	else:
		pants_label.text = "None"
	pants_color_picker_button.get_picker().color = appearance.pants_color
	if appearance.ring_choice > 0:
		rings_label.text = rings[appearance.ring_choice].name
	else:
		rings_label.text = "None"
	ring_color_picker_button.get_picker().color = appearance.ring_color
	gem_color_picker_button.get_picker().color = appearance.gem_color
	if appearance.earring_choice > 0:
		earrings_label.text = earrings[appearance.earring_choice].name
	else:
		earrings_label.text = "None"
	earring_color_picker_button.get_picker().color = appearance.earring_color
	if appearance.shoe_choice > 0:
		shoes_label.text = shoes[appearance.shoe_choice].name
	else:
		shoes_label.text = "None"
	shoes_color_picker_button.get_picker().color = appearance.shoe_color


func _on_color_picked(color: Color, color_picker_button: ColorPickerButton) -> void:
	match color_picker_button:
		skin_color_picker_button: change_color(color, body)
		eye_color_picker_button: change_color(color, eyes[current_eyes_index])
		pupil_color_picker_button: change_color(color, eyes[current_eyes_index], 1)
		hat_color_picker_button: change_color(color, hats[current_hat_index])
		shirt_color_picker_button: change_color(color, shirts[current_shirt_index])
		pants_color_picker_button: change_color(color, pants[current_pants_index])
		ring_color_picker_button: change_color(color, rings[current_ring_index])
		gem_color_picker_button: change_color(color, rings[current_ring_index], 1)
		earring_color_picker_button: change_color(color, earrings[current_earring_index])
		shoes_color_picker_button: change_color(color, shoes[current_shoes_index])


func _on_slider_changed(value: float, h_slider: HSlider, ) -> void:
	var index: int
	match h_slider:
		head_h_slider:
			index = 0
			if hats[current_hat_index] != null:
				resize_accessory(hats, current_hat_index, value)
			if eyes[current_eyes_index] != null:
				resize_accessory(eyes, current_eyes_index, value)
			if earrings[current_earring_index] != null:
				resize_accessory(earrings, current_earring_index, value)
		hands_h_slider:
			index = 1
			if rings[current_ring_index] != null:
				resize_accessory(rings, current_ring_index, value)
		feet_h_slider:
			index = 2
			if shoes[current_shoes_index] != null:
				resize_accessory(shoes, current_shoes_index, value)
	body.set_blend_shape_value(index, value)


func _on_save_pressed() -> void:
	# TODO: Reduce redundancy (which seems impossible atm)
	AudioManager.ui.set_stream(AudioManager.SUBMIT)
	AudioManager.ui.play()
	change_color(skin_color_picker_button.get_picker().color, player.body)
	if player.eyes[player.current_eyes_index] != null:
		player.eyes[player.current_eyes_index].visible = false
	player.current_eyes_index = current_eyes_index
	if player.eyes[player.current_eyes_index] != null:
		player.eyes[player.current_eyes_index].visible = true
	change_color(eye_color_picker_button.get_picker().color, player.eyes[player.current_eyes_index])
	change_color(pupil_color_picker_button.get_picker().color, player.eyes[player.current_eyes_index], 1)
	if player.hats[player.current_hat_index] != null:
		player.hats[player.current_hat_index].visible = false
	player.current_hat_index = current_hat_index
	if player.hats[player.current_hat_index] != null:
		player.hats[player.current_hat_index].visible = true
	change_color(hat_color_picker_button.get_picker().color, player.hats[player.current_hat_index])
	if player.shirts[player.current_shirt_index] != null:
		player.shirts[player.current_shirt_index].visible = false
	player.current_shirt_index = current_shirt_index
	if player.shirts[player.current_shirt_index] != null:
		player.shirts[player.current_shirt_index].visible = true
	change_color(shirt_color_picker_button.get_picker().color, player.shirts[player.current_shirt_index])
	if player.pants[player.current_pants_index] != null:
		player.pants[player.current_pants_index].visible = false
	player.current_pants_index = current_pants_index
	if player.pants[player.current_pants_index] != null:
		player.pants[player.current_pants_index].visible = true
	change_color(pants_color_picker_button.get_picker().color, player.pants[player.current_pants_index])
	if player.rings[player.current_ring_index] != null:
		player.rings[player.current_ring_index].visible = false
	player.current_ring_index = current_ring_index
	if player.rings[player.current_ring_index] != null:
		player.rings[player.current_ring_index].visible = true
	change_color(ring_color_picker_button.get_picker().color, player.rings[player.current_ring_index])
	change_color(gem_color_picker_button.get_picker().color, player.rings[player.current_ring_index], 1)
	if player.earrings[player.current_earring_index] != null:
		player.earrings[player.current_earring_index].visible = false
	player.current_earring_index = current_earring_index
	if player.earrings[player.current_earring_index] != null:
		player.earrings[player.current_earring_index].visible = true
	change_color(earring_color_picker_button.get_picker().color, player.earrings[player.current_earring_index])
	if player.shoes[player.current_shoes_index] != null:
		player.shoes[player.current_shoes_index].visible = false
	player.current_shoes_index = current_shoes_index
	if player.shoes[player.current_shoes_index] != null:
		player.shoes[player.current_shoes_index].visible = true
	change_color(shoes_color_picker_button.get_picker().color, player.shoes[player.current_shoes_index])
	resize_whole_body()
	saved.emit()


func _on_cancel_pressed() -> void:
	AudioManager.ui.set_stream(AudioManager.SUBMIT)
	AudioManager.ui.play()
	fully_revert_ui()


func _on_accessory_button_pressed(button: Button) -> void:
	var category: String = button.get_parent().name
	var is_next: int = 1 if button.text == ">" else -1
	AudioManager.ui.play()
	match category:
		"Eyes":
			current_eyes_index = change_accessory(
				is_next, eyes, current_eyes_index, total_eyes, eye_color_picker_button.get_picker().color, eyes_label, pupil_color_picker_button.get_picker().color)
		"Hats":
			current_hat_index = change_accessory(
				is_next, hats, current_hat_index, total_hats, hat_color_picker_button.get_picker().color, hats_label)
		"Shirts": 
			current_shirt_index = change_accessory(
				is_next, shirts, current_shirt_index, total_shirts, shirt_color_picker_button.get_picker().color, shirts_label)
		"Pants":
			current_pants_index = change_accessory(
				is_next, pants, current_pants_index, total_pants, pants_color_picker_button.get_picker().color, pants_label)
		"Rings":
			current_ring_index = change_accessory(
				is_next, rings, current_ring_index, total_rings, ring_color_picker_button.get_picker().color, rings_label, gem_color_picker_button.get_picker().color)
		"Earrings":
			current_earring_index = change_accessory(
				is_next, earrings, current_earring_index, total_earrings, earring_color_picker_button.get_picker().color, earrings_label)
		"Shoes":
			current_shoes_index = change_accessory(
				is_next, shoes, current_shoes_index, total_shoes, shoes_color_picker_button.get_picker().color, shoes_label)
