extends Node3D

@export var customer_dialogue_box : Control
@onready var helper_functions = %HelperFunctions

const MAX_REP = 100
const ORDER_TIME = 60.0
const CUSTOMER_DISTANCE = .6
const DAY_TIME = 240

@onready var player: Node3D = %Player
@onready var order_time_progress_bar: TextureProgressBar = %OrderTimeProgressBar
@onready var day_clock: Label = %DayClock

@onready var reputation = GameState.reputation :
	set(val):
		GameState.reputation = clamp(val, 0, MAX_REP)
		reputation = GameState.reputation
		if GameState.reputation == 0:
			no_rep_reached.emit()
		elif GameState.reputation == MAX_REP:
			max_rep_reached.emit()
	get():
		return GameState.reputation
@onready var day: int = GameState.day
@onready var profits: float = GameState.profits
var time_left: float = 0.0

var day_running: bool = false
var customer_ready: bool = false :
	set(val):
		if val:
			show_customer_dialogue()
		else:
			hide_customer_dialogue()
		customer_ready = val
var current_customer: Node3D = null
var current_order: Array = []
var order_info_arr : Array
var is_evil: bool = false
var has_pulled_gun: bool = false
var order_time_left: float = 0.0
var order_timer_running: bool = false

signal max_rep_reached
signal no_rep_reached

func _ready() -> void:
	print(Const.Items)
	player.turned_to_customer.connect(_on_player_turned_to_customer)
	player.customer_interaction.connect(_on_customer_interaction)
	player.picked_up_item.connect(_on_picked_up_item)
	order_time_progress_bar.max_value = ORDER_TIME
	start_day()

func _on_picked_up_item() -> void:
	if is_evil and customer_ready:
		%CustomerBonusAnims.play("pull_gun")

func _on_customer_bonus_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"pull_gun" and customer_ready:
		%CustomerBonusAnims.play("shoot_gun")
	elif anim_name == &"shoot_gun":
		SceneTransition.change_scene("res://UI/GameOver.tscn")

func _physics_process(delta: float) -> void:
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
	if item == null or not customer_ready:
		return
	if item.is_gun:
		kill_customer()
	elif not has_pulled_gun:
		progress_customer_order(item)
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
	order_info_arr.clear()
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
	
	update_customer_dialogue_simple(Const.StartSentArr.pick_random())
	await get_tree().create_timer(2).timeout
	order_info_arr = helper_functions.gen_order_dialog(current_order)
	update_customer_dialogue(order_info_arr)
	
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
	var available_items = Const.Items.values().duplicate()
	var chosen_items = []
	for i in range(min(items_count, Const.Items.keys().size())):
		var item = available_items.pick_random()
		chosen_items.append(item as Const.Items)
		available_items.erase(item)
	chosen_items.shuffle()
	return chosen_items
	
func progress_customer_order(item : Item):
	var wrong_order = false
	var all_orders_of_type = order_info_arr[1].filter(func(x): return x.type == item.type)
	if current_order.has(item.type):
		current_order.pop_at(current_order.find(item.type))
		var filtered_orders = all_orders_of_type.filter(func(x): return x.completion == Const.OrderCompletions.Neutral)
		if filtered_orders.size() > 0:
			filtered_orders[0].completion = Const.OrderCompletions.Good
	else:
		wrong_order = true
		var filtered_orders = order_info_arr[1].filter(func(x): return x.completion == Const.OrderCompletions.Neutral)
		if filtered_orders.size() > 0:
			filtered_orders[0].completion = Const.OrderCompletions.Bad
	print(wrong_order)

	update_customer_dialogue(order_info_arr)
	#if order_info_arr[1].all(func(x): return x.completion == Const.OrderCompletions.Bad):
	if wrong_order:
		await get_tree().create_timer(.5).timeout
		order_failed()
		return

	if current_order.size() <= 0:
		complete_customer_order()

func complete_customer_order() -> void:
	if not is_instance_valid(current_customer) or not customer_ready:
		return
	update_customer_dialogue_simple(Const.GoodEndingSentArr.pick_random())
	await get_tree().create_timer(2).timeout
	profits += 10
	reputation = reputation + 2
	await despawn_customer()
	spawn_next_customer()

func kill_customer() -> void:
	if not is_instance_valid(current_customer) or not customer_ready:
		return
	if is_evil and has_pulled_gun:
		reputation = reputation+2
	elif is_evil:
		reputation = reputation-10
	else:
		reputation = reputation-20
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
	await save_game_state()
	SceneTransition.change_scene("res://UI/BetweenDays.tscn")

func order_failed():
	if not customer_ready:
		return
	order_timer_running = false
	customer_ready = false
	update_customer_dialogue_simple(Const.BadEndingSentArr.pick_random())
	await get_tree().create_timer(2).timeout
	reputation = reputation - 10
	await despawn_customer()
	print("order failed")
	spawn_next_customer()

func show_customer_dialogue():
	customer_dialogue_box.fade_in()

func update_customer_dialogue(gen_arr: Array):
	customer_dialogue_box.fill_text(gen_arr)

func update_customer_dialogue_simple(txt: String):
	customer_dialogue_box.fill_simple_text(txt)

func hide_customer_dialogue():
	customer_dialogue_box.visible = false
	customer_dialogue_box.fade_out()
	customer_dialogue_box.clear_text()

func save_game_state():
	GameState.day = day
	GameState.reputation = reputation
	GameState.profits = profits
