extends Control

@onready var player: CharacterBody3D = $"../Player"
@onready var body: MeshInstance3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/human/MaleRig/Skeleton3D/MaleMesh
@onready var camera: Camera3D = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/SubViewportMargin/SubViewportContainer/SubViewport/Camera3D

@onready var skin_color_picker_button: ColorPickerButton = %SkinColorPickerButton
@onready var picker_buttons: Array[ColorPickerButton] = [
	skin_color_picker_button
]

@onready var radius_h_slider = %RadiusHSlider
@onready var h_sliders: Array[HSlider] = [
	radius_h_slider
]

var materials_loaded: bool = false

func _ready() -> void:
	visible = false
	for color_picker_button in picker_buttons:
		color_picker_button.color_changed.connect(_on_color_picked.bind(color_picker_button))
		var color_picker: ColorPicker = color_picker_button.get_picker()
		color_picker.sampler_visible = false
		color_picker.color_modes_visible = false
		color_picker.sliders_visible = false
		color_picker.hex_visible = false
		color_picker.presets_visible = false
	for h_slider in h_sliders:
		h_slider.value_changed.connect(_on_slider_changed.bind(h_slider))


func _process(_delta: float) -> void:
	pass


func _on_color_picked(color: Color, _color_picker_button: ColorPickerButton) -> void:
	var old_material = body.get_active_material(0) as StandardMaterial3D
	if old_material:
		var new_material = old_material.duplicate() as StandardMaterial3D
		new_material.albedo_color = color
		body.set_surface_override_material(0, new_material)
	else:
		print("No material found!")


#func _on_color_picked(color: Color, _color_picker_button: ColorPickerButton) -> void:
	#var old_material = player.body.get_active_material(0) as StandardMaterial3D
	#if old_material:
		#var new_material = old_material.duplicate() as StandardMaterial3D
		#new_material.albedo_color = color
		#player.body.set_surface_override_material(0, new_material)
	#else:
		#print("No material found!")


func _on_slider_changed(value: float, h_slider: HSlider) -> void:
	print(value)
