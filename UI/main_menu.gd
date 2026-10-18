extends Control

func _on_play_pressed() -> void:
	GameState.reset()
	SceneTransition.change_scene("res://main.tscn")

func _on_credits_pressed() -> void:
	SceneTransition.change_scene("res://UI/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_musics_finished() -> void:
	%Musics.play()
