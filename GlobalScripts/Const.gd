extends Node

const Gun = -1

enum Items {
	CheeseBurger,
	HamBurger,
	Fries,
	OnionRings,
	ChickenWings,
	MilkShake,
	Water,
	Soda,
}

enum OrderCompletions {
	Neutral,
	Bad,
	Good,
}

var TextHighlightsDict = {
	OrderCompletions.Neutral: Color.ROYAL_BLUE,
	OrderCompletions.Bad: Color.INDIAN_RED,
	OrderCompletions.Good: Color.SEA_GREEN,
}

@export var ItemsSlangDict : Dictionary[Items, Array]

@export var StartSentArr : Array[String]
@export var OrderSentArr : Array[String]
@export var EndDialogueSentArr : Array[String]
@export var GoodEndingSentArr : Array[String]
@export var BadEndingSentArr : Array[String]

func get_font_color(type : OrderCompletions):
	return TextHighlightsDict[type]
