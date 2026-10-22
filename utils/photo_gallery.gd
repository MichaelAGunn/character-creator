extends Control

@onready var grid: GridContainer = $Background/VBoxContainer/Photos/ScrollContainer/GridContainer
@onready var full_view: TextureRect = $Background/VBoxContainer/Photos/FullViewBG/MarginContainer/FullView
@onready var full_view_bg: ColorRect = $Background/VBoxContainer/Photos/FullViewBG
@onready var delete_button: Button = $Background/VBoxContainer/Buttons/Delete
@onready var back_button: Button = $Background/VBoxContainer/Buttons/Back
@onready var count_label: Label = $Background/VBoxContainer/Header/PhotoCount

var current_full_path: String = ""

func _ready() -> void:
	full_view.hide()
	full_view_bg.hide()
	delete_button.hide()
	back_button.pressed.connect(_on_back_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	PhotoManager.photos_changed.connect(populate_gallery)
	populate_gallery()


func populate_gallery() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	var photos = PhotoManager.get_all_photos()
	count_label.text = "%d / %d photos" % [photos.size(), PhotoManager.MAX_PHOTOS]
	
	for path in photos:
		var tex = PhotoManager.load_photo_as_texture(path)
		if tex:
			var btn = TextureButton.new()
			btn.texture_normal = tex
			btn.custom_minimum_size = Vector2(220, 160)
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.pressed.connect(_on_thumbnail_pressed.bind(path, tex))
			grid.add_child(btn)


func _on_thumbnail_pressed(path: String, tex: ImageTexture) -> void:
	current_full_path = path
	full_view.texture = tex
	full_view.show()
	full_view_bg.show()
	delete_button.show()


func _on_delete_button_pressed() -> void:
	if current_full_path != "":
		PhotoManager.delete_photo(current_full_path)
		_close_full_view()


func _on_back_button_pressed() -> void:
	hide()


func _close_full_view() -> void:
	full_view.hide()
	full_view_bg.hide()
	delete_button.hide()
	current_full_path = ""
