extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func _ready() -> void:
	rect.color.a = 0

func change_scene(path: String) -> void:
	var tween := create_tween()
	tween.tween_property(rect, "color:a", 1.0, 0.35)
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().scene_changed
	tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.35)
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
