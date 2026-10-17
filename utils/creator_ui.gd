extends Control

const TOON = preload("uid://dvnq1gtre07ho")

@export var player: Player

# Subviewport Assets
@onready var skeleton = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/elokido/Rig/Skeleton3D
@onready var body: MeshInstance3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/elokido/Rig/Skeleton3D/Mesh#$MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/human/MaleRig/Skeleton3D/MaleMesh
@onready var sub_viewport = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport
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
@onready var radius_h_slider = %RadiusHSlider
@onready var h_sliders: Array[HSlider] = [
	radius_h_slider
]

# Lists of Accessories
@onready var eyes_prev = %EyesPrev
@onready var eyes_label = %EyesLabel
@onready var eyes_next = %EyesNext
@onready var hats_prev: Button = %HatsPrev
@onready var hats_label = %HatsLabel
@onready var hats_next: Button = %HatsNext
@onready var shirts_prev: Button = %ShirtsPrev
@onready var shirts_label = %ShirtsLabel
@onready var shirts_next: Button = %ShirtsNext
@onready var pants_prev: Button = %PantsPrev
@onready var pants_label = %PantsLabel
@onready var pants_next: Button = %PantsNext
@onready var rings_prev: Button = %RingsPrev
@onready var rings_label = %RingsLabel
@onready var rings_next: Button = %RingsNext
@onready var earrings_prev: Button = %EarringsPrev
@onready var earrings_label = %EarringsLabel
@onready var earrings_next: Button = %EarringsNext
@onready var shoes_prev: Button = %ShoesPrev
@onready var shoes_label = %ShoesLabel
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
@onready var save_button = %SaveButton
@onready var cancel_button = %CancelButton

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
	
	var shader := ShaderMaterial.new()
	shader.shader = TOON
	shader.set_shader_parameter("use_stepped", false)
	
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
			# Apply shader material
			for surface in range(child.get_surface_override_material_count()):
				child.set_surface_override_material(surface, shader.duplicate())
			# Sort the accessories
			var category: String = child.name.get_slice("_", 0)
			if child.name != "Mesh":
				child.name = child.name.get_slice("_", 1)
				child.visible = false
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
	var old_material = node.get_active_material(slot) as ShaderMaterial#StandardMaterial3D
	if old_material:
		var new_material = old_material.duplicate() as ShaderMaterial#StandardMaterial3D
		#new_material.albedo_color = new_color
		new_material.set_shader_parameter("albedo_color", new_color)
		node.set_surface_override_material(slot, new_material)
	else:
		print("No material found!")


func change_accessory( direction: int, list: Array, index: int, total: int, picker: ColorPickerButton, label: Label, picker2: ColorPickerButton = null) -> int:
	var old_acc: MeshInstance3D = list[index]
	if old_acc != null:
		old_acc.visible = false
	index = wrap(index + direction, 0, total)
	var new_acc: MeshInstance3D = list[index]
	if new_acc != null:
		new_acc.visible = true
		label.text = new_acc.name
		change_color(picker.get_picker().color, new_acc)
		# TODO: Add second colour to eyes!
		if new_acc.mesh.get_surface_count() > 1:
			change_color(picker2.get_picker().color, new_acc, 1)
	else:
		label.text = "None"
	return index


func revert_color(picker: ColorPickerButton, color: Color, target: MeshInstance3D, slot: int = 0) -> void:
	picker.set_pick_color(color)
	change_color(color, target, slot)


func revert_accessory(list: Array, index: int, _player_list: Array, player_index: int, _picker: ColorPickerButton, label: Label) -> int:
	if index != player_index:
		if list[index] != null:
			list[index].visible = false
		index = player_index
		if list[index] != null:
			list[index].visible = true
			label.text = list[index].name
	return index


func fully_revert_ui() -> void:
	var revert_to_color: Color = player.body.get_active_material(0).get_shader_parameter("albedo_color")
	revert_color(skin_color_picker_button, revert_to_color, body)
	current_eyes_index = revert_accessory(eyes, current_eyes_index, player.eyes, player.current_eyes_index, eye_color_picker_button, eyes_label)
	if player.eyes[current_eyes_index] != null:
		revert_to_color = player.eyes[player.current_eyes_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(hat_color_picker_button, revert_to_color, hats[current_hat_index])
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
		revert_to_color = player.rings[player.current_ring_index].get_active_material(1).get_shader_parameter("albedo_color")
		revert_color(ring_color_picker_button, revert_to_color, rings[current_ring_index])
	current_earring_index = revert_accessory(earrings, current_earring_index, player.earrings, player.current_earring_index, earring_color_picker_button, earrings_label)
	if player.earrings[current_earring_index] != null:
		revert_to_color = player.earrings[player.current_earring_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(earring_color_picker_button, revert_to_color, earrings[current_earring_index])
	current_shoes_index = revert_accessory(shoes, current_shoes_index, player.shoes, player.current_shoes_index, shoes_color_picker_button, shoes_label)
	if player.shoes[current_shoes_index] != null:
		revert_to_color = player.shoes[player.current_shoes_index].get_active_material(0).get_shader_parameter("albedo_color")
		revert_color(shoes_color_picker_button, revert_to_color, shoes[current_shoes_index])


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


func _on_slider_changed(value: float, h_slider: HSlider) -> void:
	print(value)


func _on_save_pressed() -> void:
	# TODO: Reduce redundancy (which seems impossible atm)
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
	saved.emit()


func _on_cancel_pressed() -> void:
	fully_revert_ui()


func _on_accessory_button_pressed(button: Button) -> void:
	var category: String = button.get_parent().name
	var is_next: int = 1 if button.text == ">" else -1
	match category:
		"Eyes":
			current_eyes_index = change_accessory(
				is_next, eyes, current_eyes_index, total_eyes, eye_color_picker_button, eyes_label, pupil_color_picker_button)
		"Hats":
			current_hat_index = change_accessory(
				is_next, hats, current_hat_index, total_hats, hat_color_picker_button, hats_label)
		"Shirts": 
			current_shirt_index = change_accessory(
				is_next, shirts, current_shirt_index, total_shirts, shirt_color_picker_button, shirts_label)
		"Pants":
			current_pants_index = change_accessory(
				is_next, pants, current_pants_index, total_pants, pants_color_picker_button, pants_label)
		"Rings":
			current_ring_index = change_accessory(
				is_next, rings, current_ring_index, total_rings, ring_color_picker_button, rings_label, gem_color_picker_button)
		"Earrings":
			current_earring_index = change_accessory(
				is_next, earrings, current_earring_index, total_earrings, earring_color_picker_button, earrings_label)
		"Shoes":
			current_shoes_index = change_accessory(
				is_next, shoes, current_shoes_index, total_shoes, shoes_color_picker_button, shoes_label)
