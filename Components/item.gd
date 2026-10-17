extends StaticBody3D 
class_name Item

## Invalidates type if true.
@export var is_gun : bool = false
@export var type : Const.Items
@onready var is_picked_up : bool = false
var is_tweening : bool = false
var marker : Marker3D
@onready var initial_pos : Vector3
@onready var initial_rot : Vector3
@export var item_mesh : Node3D

func pick_up(pick_marker : Marker3D):
	initial_pos = self.global_position
	initial_rot = self.global_rotation
	marker = pick_marker
	is_picked_up = true

func _physics_process(_delta: float) -> void:
	if is_picked_up:
		self.global_position = marker.global_position
		self.global_rotation = marker.global_rotation

func tween_activate():
	if is_tweening: return
	is_tweening = true
	var initial_scale = item_mesh.scale
	var tween = create_tween()
	tween.tween_property(item_mesh, "scale", item_mesh.scale * Vector3(0.8, 0.8, 1.4), 0.2)
	tween.tween_property(item_mesh, "scale", initial_scale, 0.1)
	await tween.finished
	is_tweening = false
