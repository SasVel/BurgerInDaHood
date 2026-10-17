extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate.a = 0
	self.visible = false

func fill_text(gen_arr : Array):
	fade_in()
	%Label.fill_text(gen_arr)

func clear_text():
	%Label.text = ""

func fade_in():
	self.visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.1)

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.1)
	self.visible = false
