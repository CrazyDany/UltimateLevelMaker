class_name AudioPlayer extends Node

@export var sound_list: Array[AudioStreamPlayer]
@export var music_list: Array[AudioStreamPlayer]

var sound_dictionary: Dictionary

func sound_list_to_dictionary() -> void: 
	for audio in sound_list:
		if not sound_list.has(audio.name):
			sound_dictionary[audio.name] = audio

func _ready():
	sound_list_to_dictionary()
	
func play_sound(sound: String):
	if sound_dictionary.has(sound):
		sound_dictionary[sound].play()
	
