extends Node

const SONG = preload("uid://k4oey4svjk6s")
const CYCLE = preload("uid://b2gc3axybl2lx")
const SUBMIT = preload("uid://1m0wwwqgrdn3")
const STEP_SHORT = preload("uid://cuvsd2kvp3qhp")
const STEP_MED = preload("uid://cspkp45aaglim")
const STEP_LONG = preload("uid://bj7f2snogw3uw")

@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var ui: AudioStreamPlayer = $UIPlayer
@onready var char: AudioStreamPlayer = $CharPlayer

var connected = false

func _ready():
	print(music.name)
	print(ui.name)
	print(char.name)
	music.finished.connect(_on_song_finished)
	music.set_stream(SONG)
	music.playing = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if connected:
		return
	
	connected = true


func _on_song_finished() -> void:
	if music.playing == false:
		music.playing = true
