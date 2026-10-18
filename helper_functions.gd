extends Node3D

## Returns an array with first entry being the text and second a dict with word -> chosen slang.
func gen_listing(arr) -> Array:
	var count = arr.size()
	
	var result = ""
	var item
	var slang
	if(count <= 0):
		return []
		
	elif(count == 1):
		item = Const.Items[arr[0]]
		slang = Const.ItemsSlangDict[item].pick_random()
		result = "[i]" + slang + "[/i]"
		return [result, ItemData.new().init(item, slang, Const.OrderCompletions.Neutral)]

	var res_datas : Array[ItemData]
	for i in range(count):
		item = arr[i] as Const.Items
		slang = Const.ItemsSlangDict[item].pick_random()
		result += "[i]" + slang + "[/i]"

		if res_datas.map(func(x): return x.type).has(item):
			res_datas.filter(func(x): return x.type == item)[0].count += 1
		else:
			res_datas.append(ItemData.new().init(item, slang, Const.OrderCompletions.Neutral))
		
		if(i == count - 1):
			break
		elif(i == count - 2):
			result += " 'n "
			print("item case 2!!!")
			continue
		
		result += ", "
	
	return [result, res_datas]

## Returns an array with first entry being the text and second a dict with word -> chosen slang.
func gen_order_dialog(arr)->Array:
	var result = "";
	
	result += Const.OrderSentArr.pick_random()
	
	var order_size = arr.size();
	var generated_arr = gen_listing(arr)
	result += generated_arr[0]
	
	result += Const.EndDialogueSentArr.pick_random()
	
	print(result)
	return [result, generated_arr[1]]
