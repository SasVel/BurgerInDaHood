
extends Control

@onready var rep: Label = %Rep
@onready var day: Label = %Day
@onready var savings: RichTextLabel = %Savings
@onready var profits: RichTextLabel = %Profits
@onready var rent: RichTextLabel = %Rent
@onready var total: RichTextLabel = %Total
@onready var next_day_button: Button = %NextDayButton

@export var reveal_delay: float = 0.35

var rent_value: float
var old_money: float

func _ready() -> void:
	next_day_button.visible = false
	rent_value = 100 + GameState.day * 10
	old_money = GameState.money
	GameState.money = old_money + GameState.profits - rent_value
	var filled := int(GameState.reputation / 20.0)

	day.modulate.a = 0.0
	rep.modulate.a = 0.0
	savings.modulate.a = 0.0
	profits.modulate.a = 0.0
	rent.modulate.a = 0.0
	total.modulate.a = 0.0

	day.text = "Day " + str(GameState.day)
	rep.text = "Reputation: " + "★".repeat(filled) + "☆".repeat(5 - filled)
	savings.text = "Savings: [color=green]" + str(old_money) + "$ [/color]"
	profits.text = "Daily Profits: [color=green]" + str(GameState.profits) + "$ [/color]"
	rent.text = "Rent: [color=red]" + str(rent_value) + "$ [/color]"
	if GameState.money < 0:
		total.text = "Total: [color=red]" + str(GameState.money) + "$ [/color]"
	else:
		total.text = "Total: [color=green]" + str(GameState.money) + "$ [/color]"

	await reveal(day)
	await get_tree().create_timer(0.2).timeout
	await reveal(rep)
	await get_tree().create_timer(reveal_delay).timeout
	await reveal(savings)
	await get_tree().create_timer(reveal_delay).timeout
	await reveal(profits)
	await get_tree().create_timer(reveal_delay).timeout
	await reveal(rent)
	await get_tree().create_timer(reveal_delay).timeout
	await reveal(total)
	await get_tree().create_timer(reveal_delay).timeout
	
	if(GameState.money >= 0):
		next_day_button.visible = true
	else:
		SceneTransition.change_scene("res://UI/GameOver.tscn")

func reveal(node: Control) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(node, "position:y", node.position.y - 8.0, 0.3)
	await tween.finished

func _on_next_day_button_pressed() -> void:
	SceneTransition.change_scene("res://main.tscn")
