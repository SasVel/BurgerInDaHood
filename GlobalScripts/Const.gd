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

@export var ItemsSlangDict : Dictionary[Items, Array]

@export var StartSentArr : Array[String]
@export var OrderSentArr : Array[String]
@export var EndDialogueSentArr : Array[String]
@export var GoodEndingSentArr : Array[String]
@export var BadEndingSentArr : Array[String]
