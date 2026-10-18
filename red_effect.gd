extends ColorRect

var tween : Tween

func activate():
	tween = create_tween().set_loops()
	tween.tween_property(self, "color:a", 0.2, 0.3)
	tween.tween_property(self, "color:a", 0, 0.3)

func deactivate():
	tween.stop()
	self.color.a = 0
