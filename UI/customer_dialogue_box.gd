extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

func fill_text(text : String):
	%Label.text = text
