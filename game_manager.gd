extends Node3D

const MAX_REP = 100
const CUSTOMER_DISTANCE = .7
const DAY_TIME = 100
@onready var player: Node3D = %Player
@onready var reputation = MAX_REP
var day: int = 0
var time_left: float = 0.0

var day_running: bool = false
var customer_ready: bool = false
var current_customer: Node3D = null
var current_order: Array = []
var is_evil: bool = false
var has_pulled_gun: bool = false

func _ready() -> void:
	print(Const.Items)
	player.turned_to_customer.connect(_on_player_turned_to_customer)
	player.customer_interaction.connect(_on_customer_interaction)
	start_day()

func _process(delta: float) -> void:
	if not day_running:
		return
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		end_day()

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
	print("Customer is ready. Order: ", current_order)

func despawn_customer():
	var tween = create_tween()
	tween.tween_property(current_customer,"rotation:y",current_customer.rotation.y - PI/2,0.5)
	tween.tween_property(current_customer,"position",Vector3(-2, -.7, -CUSTOMER_DISTANCE),2.0)

	await tween.finished
	
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

	print("Order completed!")
	customer_ready = false
	await despawn_customer()
	current_customer.queue_free()
	current_customer = null
	print("Customer despawned")

	spawn_next_customer()

func kill_customer() -> void:
	if not is_instance_valid(current_customer) or not customer_ready:
		return
	customer_ready = false

	var tween = create_tween()

	# Fall sideways by rotating 90 degrees
	tween.tween_property(current_customer,"rotation:z",current_customer.rotation.z + deg_to_rad(90),0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Wait briefly, then disappear
	tween.tween_interval(0.5)

	# Fade out by scaling down
	tween.tween_property(
		current_customer,
		"scale",
		Vector3.ZERO,
		0.3
	)

	await tween.finished
	current_customer.queue_free()
	current_customer = null
	if day_running:
		spawn_next_customer()
	print("kill customer")

func end_day() -> void:
	day_running = false
	customer_ready = false

	print("Day ", day, " ended!")
	print("Reputation: ", reputation)

	if is_instance_valid(current_customer):
		current_customer.queue_free()

	current_customer = null

	# TODO: Show end-of-day results.
	# Call start_day() when the player chooses to continue.
