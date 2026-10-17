extends Resource
class_name ItemData

@export var type : Const.Items
@export var chosen_slang : String
@export var completion : Const.OrderCompletions
@export var count : int = 1

func init(type_, chosen_slang_, completion_, count_ = 1):
	type = type_
	chosen_slang = chosen_slang_
	completion = completion_
	count = count_
	return self
