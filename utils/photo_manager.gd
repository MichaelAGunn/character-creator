extends Node

const PHOTO_DIR: String = "user://photos/"
const MAX_PHOTOS: int = 32
const CAPTURE_WIDTH_RATIO: float = 0.70
const CAPTURE_ASPECT:float = 1.0#16.0 / 9.0

signal photo_taken(path: String)
signal photo_deleted(path: String)
signal photos_changed()


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(PHOTO_DIR)

func take_photo() -> String:
	await RenderingServer.frame_post_draw
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var full_image: Image = get_viewport().get_texture().get_image()
	
	# Calculate the capture rectangle in pixels
	var capture_width  = viewport_size.x * CAPTURE_WIDTH_RATIO
	var capture_height = capture_width / CAPTURE_ASPECT
	
	# Keep it inside the screen
	capture_height = min(capture_height, viewport_size.y * 0.85)
	capture_width  = capture_height * CAPTURE_ASPECT
	
	var capture_rect = Rect2(
		(viewport_size.x - capture_width)  / 2.0,   # centered X
		(viewport_size.y - capture_height) / 2.0,   # centered Y
		capture_width,
		capture_height
	)
	
	# Crop the image
	var cropped: Image = full_image.get_region(capture_rect)
	
	# Save
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var path = PHOTO_DIR + "photo_" + timestamp + ".png"
	
	var error = cropped.save_png(path)
	if error != OK:
		push_error("Failed to save photo")
		return ""
	
	_enforce_limit()
	photo_taken.emit(path)
	photos_changed.emit()
	return path
#func take_photo() -> String:
	#print("PhotoManager.take_photo()")
	## Wait until the frame is fully drawn
	#await RenderingServer.frame_post_draw
	#
	#var image: Image = get_viewport().get_texture().get_image()
	#
	#var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	#var path = PHOTO_DIR + "photo_" + timestamp + ".png"
	#
	#var error = image.save_png(path)
	#if error != OK:
		#push_error("Failed to save photo")
		#return ""
	#
	## Enforce photo limit (delete oldest if over limit)
	#_enforce_limit()
	#
	#print("Photo saved: ", path)
	#photo_taken.emit(path)
	#photos_changed.emit()
	#return path


func get_all_photos() -> PackedStringArray:
	var photos: PackedStringArray = []
	var dir = DirAccess.open(PHOTO_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				photos.append(PHOTO_DIR + file_name)
			file_name = dir.get_next()
	
	# Newest first
	photos.sort()
	photos.reverse()
	return photos


func load_photo_as_texture(path: String) -> ImageTexture:
	var image = Image.load_from_file(path)
	if image:
		return ImageTexture.create_from_image(image)
	return null


func delete_photo(path: String) -> bool:
	if FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path)
		if err == OK:
			photo_deleted.emit(path)
			photos_changed.emit()
			return true
	return false


func _enforce_limit() -> void:
	var photos = get_all_photos()
	while photos.size() > MAX_PHOTOS:
		var oldest = photos.pop_back()
		delete_photo(oldest)
