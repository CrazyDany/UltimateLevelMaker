class_name AudioPlayer extends Node

@export var sound_folder:StringName = "res://sounds/"

var sound_dictionary: Dictionary

func _ready():
	var sound_dir = DirAccess.open(sound_folder)
	if sound_dir:
		sound_dir.list_dir_begin()
		for file:String in sound_dir.get_files():
			var res = load(sound_dir.get_current_dir()+"/"+file)
			if res:
				if res.resource_path.ends_with(".wav"):
					var sound = AudioStreamPlayer.new()
					sound.stream = load(res.resource_path)
					var file_name:String = res.resource_path.split("/")[-1].split(".")[0]
					sound.name = file_name
					add_child(sound)
					sound_dictionary[file_name] = sound
				
func play_sound(sound: String):
	if sound_dictionary.has(sound):
		sound_dictionary[sound].play()
	else:
		assert(0, "Звук {sound} отсуствует, воспроизведение не возможно".format({"sound": sound}))
