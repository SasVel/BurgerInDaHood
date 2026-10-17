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
	var target_angle = direction * -PI / 2
	var difference = target_angle - rotation.y
	
	if abs(difference) < 0.01 || (direction == LEFT && difference < 0) || (direction == FRONT && difference > 0):
		rotation.y = target_angle
	elif difference > 0:
		rotation.y += turn_speed * delta
	else:
		rotation.y -= turn_speed * delta
	
