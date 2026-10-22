extends Control

@onready var count_label: Label = $VBoxContainer/Header/HBoxContainer/PhotoCount
@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var full_view: TextureRect = $FullView
@onready var full_view_bg: ColorRect = $FullViewBG
@onready var delete_button: Button = $FullView/Delete
@onready var close_button: Button = $FullView/Close
@onready var back_button: Button = $VBoxContainer/BottomBar/Back
@onready var prev_button = $FullView/Prev
@onready var next_button = $FullView/Next

var current_full_path: String = ""
var gallery_active: bool = false
var photos: PackedStringArray = []
var current_index: int = -1

func _ready() -> void:
	full_view.hide()
	full_view_bg.hide()
	close_button.hide()
	delete_button.hide()
	prev_button.hide()
	next_button.hide()
	
	PhotoManager.photos_changed.connect(populate_gallery)
	populate_gallery()
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	close_button.pressed.connect(_on_back_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	prev_button.pressed.connect(_on_prev_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)


func populate_gallery() -> void:
	# Clear old thumbnails
	for child in grid.get_children():
		child.queue_free()
	
	photos = PhotoManager.get_all_photos()
	count_label.text = "%d / %d photos" % [photos.size(), PhotoManager.MAX_PHOTOS]
	
	for i in photos.size():
		var path = photos[i]
		var tex = PhotoManager.load_photo_as_texture(path)
		if tex:
			var btn = TextureButton.new()
			btn.texture_normal = tex
			btn.custom_minimum_size = Vector2(220, 160)
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.pressed.connect(_on_thumbnail_pressed.bind(i))
			grid.add_child(btn)
	
	# If viewing a photo that got deleted, close full view
	if current_index >= photos.size():
		_close_full_view()


func _close_full_view() -> void:
	full_view.hide()
	full_view_bg.hide()
	close_button.hide()
	delete_button.hide()
	back_button.show()
	current_index = -1


func _on_thumbnail_pressed(index: int) -> void:
	_show_photo_at(index)


func _show_photo_at(index: int) -> void:
	if index < 0 or index >= photos.size():
		return
	
	current_index = index
	var path = photos[current_index]
	var tex = PhotoManager.load_photo_as_texture(path)
	
	if tex:
		full_view.texture = tex
		full_view.show()
		full_view_bg.show()
		close_button.show()
		delete_button.show()
		prev_button.show()
		next_button.show()
		_update_nav_buttons()


func _update_nav_buttons() -> void:
	prev_button.disabled = current_index <= 0
	next_button.disabled = current_index >= photos.size() - 1


func _on_delete_button_pressed() -> void:
	if current_index >= 0 and current_index < photos.size():
		var path = photos[current_index]
		PhotoManager.delete_photo(path)
		if current_index > 0:
			_show_photo_at(current_index - 1)
		else:
			_show_photo_at(current_index)


func _on_back_button_pressed() -> void:
	if full_view.visible:
		_close_full_view()
	else:
		hide()
		gallery_active = false


func _on_prev_button_pressed() -> void:
	_show_photo_at(current_index - 1)


func _on_next_button_pressed() -> void:
	_show_photo_at(current_index + 1)
