extends Node3D

const MAX_REP = 100
const ORDER_TIME = 15.0
const CUSTOMER_DISTANCE = .7
const DAY_TIME = 100
@onready var player: Node3D = %Player
@onready var order_time_progress_bar: TextureProgressBar = %OrderTimeProgressBar
@onready var day_clock: Label = %DayClock
@onready var reputation = MAX_REP
var day: int = 0
var time_left: float = 0.0

var day_running: bool = false
var customer_ready: bool = false
var current_customer: Node3D = null
var current_order: Array = []
var is_evil: bool = false
var has_pulled_gun: bool = false
var order_time_left: float = 0.0
var order_timer_running: bool = false

func _ready() -> void:
	print(Const.Items)
	player.turned_to_customer.connect(_on_player_turned_to_customer)
	player.customer_interaction.connect(_on_customer_interaction)
	order_time_progress_bar.max_value = ORDER_TIME
	start_day()

func _process(delta: float) -> void:
	if not day_running:
		return
	time_left -= delta
	var day_progress = 1.0 - (time_left / DAY_TIME)
	var game_hour = lerpf(9.0, 17.0, day_progress)

	var hours = int(game_hour)
	var minutes = int((game_hour - hours) * 60)

	day_clock.text = "%02d:%02d" % [hours, minutes]
	if time_left <= 0:
		time_left = 0
		end_day()
	if order_timer_running:
		order_time_left = maxf(order_time_left - delta, 0.0)
		order_time_progress_bar.value = order_time_left
	if order_time_left <= 0:
		order_failed()

func _on_customer_interaction(item):
	if item == null:
		return
	if item == Const.Gun:
		kill_customer()
	elif not has_pulled_gun:
		complete_customer_order()
	#TODO

func _on_player_turned_to_customer():
	if not day_running or not customer_ready:
		return
	if not is_instance_valid(current_customer):
		return
	if not is_evil:
		return
	if has_pulled_gun:
		return
	var reputation_percent = float(reputation) / MAX_REP
	var gun_chance = max(1-reputation_percent,.05)
	if randf() < gun_chance:
		pull_gun()

func pull_gun():
	has_pulled_gun = true
	print("customer pulled a gun")

func start_day() -> void:
	day += 1
	time_left = DAY_TIME
	day_running = true
	print("Day ", day, " started!")
	spawn_next_customer()

func spawn_next_customer() -> void:
	if not day_running or is_instance_valid(current_customer):
		return
	var reputation_percent = float(reputation) / MAX_REP
	var evil_chance = max(1-reputation_percent,.25)
	if randf() < evil_chance:
		is_evil = true
		print("is evil")
	else:
		is_evil = false
	var customer = Res.customers.pick_random()
	var instance = customer.instantiate()
	current_customer = instance
	current_order = select_order_items(2)
	customer_ready = false
	add_child(current_customer)
	current_customer.scale = Vector3(0.5, 0.5, 0.5)
	current_customer.position = Vector3(2, -0.7, -CUSTOMER_DISTANCE)
	current_customer.rotation = Vector3(0, -PI, 0)
	var tween = create_tween()
	tween.tween_property(current_customer,"position",Vector3(0, -.7, -CUSTOMER_DISTANCE),2.0)
	tween.tween_property(current_customer,"rotation:y",current_customer.rotation.y + PI/2,0.5)
	await tween.finished
	if not day_running or not is_instance_valid(current_customer):
		return
	customer_ready = true
	order_time_left = ORDER_TIME
	order_timer_running = true
	print("Customer is ready. Order: ", current_order)

func despawn_customer():
	customer_ready = false
	var tween = create_tween()
	tween.tween_property(current_customer,"rotation:y",current_customer.rotation.y - PI/2,0.5)
	tween.tween_property(current_customer,"position",Vector3(-2, -.7, -CUSTOMER_DISTANCE),2.0)
	await tween.finished
	if not current_customer == null:
		current_customer.queue_free()
		current_customer = null

func select_order_items(items_count):
	var available_items = Const.Items.keys().duplicate()
	var chosen_items = []
	for i in range(min(items_count, Const.Items.keys().size())):
		var item = available_items.pick_random()
		chosen_items.append(item)
		available_items.erase(item)
	chosen_items.shuffle()
	return chosen_items
	
func complete_customer_order() -> void:
	if not is_instance_valid(current_customer) or not customer_ready:
		return
	reputation = min(reputation + 2, MAX_REP)
	await despawn_customer()
	spawn_next_customer()

func kill_customer() -> void:
	if not is_instance_valid(current_customer) or not customer_ready:
		return
	if is_evil and has_pulled_gun:
		reputation = min(reputation+2, MAX_REP)
	elif is_evil:
		reputation = max(reputation-10, 0)
	else:
		reputation = max(reputation-20, 0)
	customer_ready = false
	var tween = create_tween()
	tween.tween_property(current_customer,"rotation:z",current_customer.rotation.z + PI/2,0.5)
	tween.tween_interval(0.5)
	await tween.finished
	current_customer.queue_free()
	current_customer = null
	spawn_next_customer()

func end_day() -> void:
	day_running = false
	await despawn_customer()
	print("Day ", day, " ended!")
	print("Reputation: ", reputation)

func order_failed():
	if not customer_ready:
		return
	order_timer_running = false
	customer_ready = false
	reputation = max(reputation - 10, 0)
	await despawn_customer()
	print("order failed")
	spawn_next_customer()
