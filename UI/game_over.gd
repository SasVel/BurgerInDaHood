extends Control


func _on_play_again_pressed() -> void:
	GameState.reset()
	SceneTransition.change_scene("res://main.tscn")


func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene("res://UI/MainMenu.tscn")
