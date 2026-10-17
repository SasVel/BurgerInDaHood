extends Node3D

signal customer_interaction

@onready var camera = $Camera3D
@export var turn_speed = 10
const FRONT = 0
const LEFT = -1
var direction = FRONT

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("turn_left"):
		direction=max(direction-1, LEFT)
	if Input.is_action_just_pressed("turn_right"):
		direction=min(direction+1, FRONT)
	
	handleRotation(delta)

func handleRotation(delta):
	var target_angle = direction * -PI / 2
	var difference = target_angle - rotation.y
	
	if abs(difference) < 0.01 or (direction == LEFT and difference < 0) or (direction == FRONT and difference > 0):
		rotation.y = target_angle
	elif difference > 0:
		rotation.y += turn_speed * delta
	else:
		rotation.y -= turn_speed * delta

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var end = origin + direction * 1000.0
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result:
			var object = result.collider
			print("You clicked on: ", object.name)
			if object.name == "CustomerHitbox":
				customer_interaction.emit()
		else:
			print("You clicked on nothing")
