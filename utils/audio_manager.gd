extends Node

const SONG = preload("uid://k4oey4svjk6s")
const CYCLE = preload("uid://b2gc3axybl2lx")
const SUBMIT = preload("uid://1m0wwwqgrdn3")
const MAIN = preload("uid://dm5wgjpd0fgj1")
const FLASH = preload("uid://dcadq36d8bpi6")

@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var ui: AudioStreamPlayer = $UIPlayer
@onready var character: AudioStreamPlayer = $CharPlayer
@onready var flash: AudioStreamPlayer = $FlashPlayer

var connected = false

func _ready():
	music.finished.connect(_on_song_finished)
	music.set_stream(SONG)
	music.playing = true
	ui.finished.connect(_on_ui_finished)
	flash.set_stream(FLASH)


func _on_song_finished() -> void:
	if music.playing == false:
		music.playing = true


func _on_ui_finished() -> void:
	if ui.pitch_scale != 1.0:
		ui.pitch_scale = 1.0
