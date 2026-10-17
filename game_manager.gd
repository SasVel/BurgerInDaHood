extends Node3D

const ORDER_ITEMS = ["coke", "burger"]
const MAX_REP = 100
const CUSTOMER_DISTANCE = .7

@onready var reputation = MAX_REP
@onready var day = 0
@onready var time = 0

func _ready() -> void:
	start_day()

func _process(delta: float) -> void:
	pass

func start_day():
	#displayDay()
	var customer = Res.customers.pick_random()
	var instance = customer.instantiate()
	spawn_customer(instance)
	
	var items_count = 2
	var selected_items = select_order_items(items_count)

func spawn_customer(instance):
	add_child(instance)
	instance.scale = Vector3(0.5, 0.5, 0.5)
	instance.position = Vector3(2, -.5, -CUSTOMER_DISTANCE)
	instance.rotation = Vector3(0, -PI, 0)
	
	var tween = create_tween()
	tween.tween_property(instance,"position",Vector3(0, -0.5, -CUSTOMER_DISTANCE),2.0)
	tween.tween_property(instance,"rotation:y",instance.rotation.y + PI/2,0.5)
	
func select_order_items(items_count):
	var available_items = ORDER_ITEMS.duplicate()
	var chosen_items = []
	for i in range(min(items_count, ORDER_ITEMS.size())):
		var item = available_items.pick_random()
		chosen_items.append(item)
		available_items.erase(item)
	chosen_items.shuffle()
	return chosen_items
