extends Node

@onready var reputation = 100
@onready var day: int = 0
@onready var profits: float = 0
@onready var money: float = 300

func reset():
	reputation = 100
	day= 0
	profits = 0
	money = 300
