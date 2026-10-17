extends Node3D

@onready var camera = $Camera3D
@export var turn_speed = 10
const FRONT = 0
const LEFT = -1
var direction = FRONT

func _process(delta):
	if Input.is_action_just_pressed("turn_left"):
		direction=max(direction-1, LEFT)
	if Input.is_action_just_pressed("turn_right"):
		direction=min(direction+1, FRONT)
	camera.rotation.y = lerp_angle(camera.rotation.y, direction * -PI / 2, turn_speed * delta)
	
