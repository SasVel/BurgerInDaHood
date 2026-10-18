extends RichTextLabel

var tags_text = \
	"[font_size=56]" + \
	"[color=BLACK]" + \
	"*" + \
	"[/color]" + \
	"[/font_size]"

## Receives an array with first entry being the text and second a dict with word -> chosen slang.
func fill_text(gen_arr : Array):
	var txt = tags_text.replace("*", gen_arr[0])
	for item_data in gen_arr[1]:
		txt = color_kw(txt, item_data.chosen_slang, Const.get_font_color(item_data.completion))
	text = txt

func fill_simple_text(val : String):
	var txt = tags_text.replace("*", val)
	text = txt

func color_kw(input_str : String, kw : String, color : Color) -> String:
	return input_str.replace(kw, ("[color=%s]" % color.to_html(false)) + kw + "[/color]")
