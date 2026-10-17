extends Node3D

func gen_listing(arr) -> String:
	var count = arr.size()
	
	if(count <= 0):
		return ""
		
	elif(count == 1):
		var item = (Const.ItemsSlangDict[Const.Items[arr[0]]]).pick_random()
		return item
	
	var result = ""
	
	for i in range(count):
		result += (Const.ItemsSlangDict[Const.Items[arr[i]]]).pick_random()
		
		if(i == count - 1):
			break
		elif(i == count - 2):
			result += " 'n "
			print("item case 2!!!")
			continue
		
		result += ", "
	
	return result

func gen_order_dialog(arr)->String:
	var result = "";
	
	result += Const.StartSentArr.pick_random() + Const.OrderSentArr.pick_random()
	
	var order_size = arr.size();
	result += gen_listing(arr)
	
	result += Const.EndDialogueSentArr.pick_random()
	
	print(result)
	return result
