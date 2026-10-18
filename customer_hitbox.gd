extends StaticBody3D
class_name CustomerHitbox

func activate(item : Item):
	if item.is_gun:
		%ScreamPlayer.play()
