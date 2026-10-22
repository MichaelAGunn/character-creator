extends Control

@onready var flash: ColorRect = $Flash
@onready var prompt: Label = $Prompt
@onready var message: Label = $Message
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var frame = $Frame
@onready var frame_top: ColorRect = $Frame/FrameTop
@onready var frame_bottom: ColorRect = $Frame/FrameBottom
@onready var frame_left: ColorRect = $Frame/FrameLeft
@onready var frame_right: ColorRect = $Frame/FrameRight

var photo_mode: bool = false

func _ready() -> void:
	flash.modulate.a = 0.0
	message.modulate.a = 0.0
	frame.visible = false
	_set_frames_visible(false)
	PhotoManager.photo_taken.connect(_on_photo_taken)
	get_viewport().size_changed.connect(_update_frame_layout)
	_update_frame_layout()
	#await get_tree().create_timer(0.3).timeout
	#frame.visible = true


func toggle_photo_mode() -> void:
	if frame.visible == false:
		frame.visible = true
	photo_mode = !photo_mode
	prompt.visible = !prompt.visible
	message.visible = !message.visible
	show_viewfinder(!message.visible)


func _on_photo_taken(_path: String) -> void:
	if photo_mode == false:
		return
		
	# Play shutter sound
	AudioManager.flash.play()
	
	# Flash
	flash.modulate.a = 0.85
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD)
	
	# Notification
	message.text = "Photo saved!"
	message.modulate.a = 1.0
	var notif_tween = create_tween()
	notif_tween.tween_interval(1.2)
	notif_tween.tween_property(message, "modulate:a", 0.0, 0.4)


func show_viewfinder(visibility: bool = true) -> void:
	_set_frames_visible(visibility)
	if visible:
		_update_frame_layout()


func _set_frames_visible(visibility: bool) -> void:
	if visibility:
		anim.play("show_frame")
	else:
		anim.play("hide_frame")


func _update_frame_layout() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	var capture_width: float = viewport_size.x * PhotoManager.CAPTURE_WIDTH_RATIO
	var capture_height: float = capture_width / PhotoManager.CAPTURE_ASPECT
	capture_height = min(capture_height, viewport_size.y * 0.85)
	capture_width = capture_height * PhotoManager.CAPTURE_ASPECT
	
	var left: float = (viewport_size.x - capture_width)  / 2.0
	var top: float = (viewport_size.y - capture_height) / 2.0
	var right: float = left + capture_width
	var bottom: float = top + capture_height + 1.0 # TODO: This is a bandaid solution!
	
	# Top bar
	frame_top.position = Vector2(0, 0)
	frame_top.size = Vector2(viewport_size.x, top)
	# Bottom bar
	frame_bottom.position = Vector2(0, bottom)
	frame_bottom.size = Vector2(viewport_size.x, viewport_size.y - bottom)
	# Left bar
	frame_left.position = Vector2(0, top)
	frame_left.size = Vector2(left, capture_height)
	# Right bar
	frame_right.position = Vector2(right, top)
	frame_right.size = Vector2(viewport_size.x - right, capture_height)
