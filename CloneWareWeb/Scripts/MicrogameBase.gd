extends Node
class_name Microgame

signal microgame_finished(win: bool)

var microgame_description := "Let's Go!"
var description_font_size := 24

func difficuty_set() -> void:
	pass

func finish_game(win: bool):
	AudioManager.stop_music()
	
	await get_tree().create_timer(0.5).timeout
	emit_signal("microgame_finished", win)
	#self.process_mode = Node.PROCESS_MODE_DISABLED
