extends Control

signal LevelUpChoiceMade(ability: AbilityData)

@onready var buttons := [
	$EntireThing/Ability1/Button, $EntireThing/Ability2/Button2, $EntireThing/Ability3/Button3
]

var offered_abilities: Array[AbilityData] = []

func setup(abilities: Array[AbilityData]) -> void:
	offered_abilities = abilities

	for i in buttons.size():
		var ability := offered_abilities[i]
		buttons[i].text = ability.id
		buttons[i].pressed.connect(_on_button_pressed.bind(i))

func _on_button_pressed(index: int) -> void:
	LevelUpChoiceMade.emit(offered_abilities[index])
	queue_free()
