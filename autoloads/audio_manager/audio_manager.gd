extends Node


const music = preload("res://assets/audio/music/mimei no radio kara.mp3")

const sounds = {}

const safe_sounds = {}
const danger_sounds = {}

@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	music_player.stream = music
	music_player.play()


func play_sound(sound_name: String, pitch: float = 1.0) -> void:
	if not sounds.has(sound_name):
		push_error(sound_name + " is not a valid sound")
		return

	play_sound_from_stream(sounds[sound_name], pitch)


func play_sound_from_stream(stream: AudioStream, pitch: float = 1.0) -> void:
	var player := AudioStreamPlayer.new()
	player.pitch_scale = pitch
	player.stream = stream
	player.bus = "SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
