extends Resource
class_name AbilityData

@export var id: String
@export var icon: Texture2D
@export var cooldown: float = 1.0
@export var description: String
@export var ProjectileSpeed: float
@export_enum("Main", "Secondary", "Utility", "Passive")
var slot: String
