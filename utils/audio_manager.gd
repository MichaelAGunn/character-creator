extends Node

const SONG = preload("uid://k4oey4svjk6s")
const CYCLE = preload("uid://b2gc3axybl2lx")
const SUBMIT = preload("uid://1m0wwwqgrdn3")

@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var ui: AudioStreamPlayer = $UIPlayer
@onready var char: AudioStreamPlayer = $CharPlayer

var connected = false

func _ready():
	music.finished.connect(_on_song_finished)
	music.set_stream(SONG)
	music.playing = true


func _on_song_finished() -> void:
	if music.playing == false:
		music.playing = true
