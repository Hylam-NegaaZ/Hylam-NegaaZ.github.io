extends Node

var active_music : AudioStreamPlayer
var active_sfx : AudioStreamPlayer

@onready var clips : Node = $Clips

func play_music(audio_name: String):
	stop_music()
	if clips == null:
		push_error("clips is not assigned in the Inspector!")
		return

	if not clips.has_node(audio_name):
		push_error("No MUSIC called '%s' found under %s" % [audio_name, clips.name])
		return

	active_music = clips.get_node(audio_name) as AudioStreamPlayer
	active_music.play()

func play_sfx(audio_name: String):
	if clips == null:
		push_error("clips is not assigned in the Inspector!")
		return

	if not clips.has_node(audio_name):
		push_error("No SFX called '%s' found under %s" % [audio_name, clips.name])
		return
		
	active_sfx = clips.get_node(audio_name) as AudioStreamPlayer
	active_sfx.play()

func stop_music():
	if active_music and is_instance_valid(active_music):
		active_music.stop()
