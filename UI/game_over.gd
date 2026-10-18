extends Control

@onready var day_count: Label = %DayCount

func _ready() -> void:
	day_count.text = "You survived for " + str(GameState.day) + " day" + ("s" if GameState.day > 1 else "") + " in da hood"
	
func _on_play_again_pressed() -> void:
	GameState.reset()
	SceneTransition.change_scene("res://main.tscn")


func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene("res://UI/MainMenu.tscn")
