extends Node3D

const ORDER_ITEMS = ["coke", "burger"]
const CUSTOMERS = [1,2,3]
const MAX_REP = 100

@onready var reputation = MAX_REP
@onready var day = 0
@onready var time = 0

func _ready() -> void:
	start_day()

func _process(delta: float) -> void:
	pass

func start_day():
	#displayDay()
	var customer = CUSTOMERS.pick_random()
	#var instance = customer.instantiate()
	#add_child(instance)
	var items_count = 2
	var selected_items = select_order_items(items_count)
	
	
func select_order_items(items_count):
	var available_items = ORDER_ITEMS.duplicate()
	var chosen_items = []
	for i in range(items_count):
		var item = available_items.pick_random()
		chosen_items.append(item)
		available_items.erase(item)
	chosen_items.shuffle()
	return chosen_items
