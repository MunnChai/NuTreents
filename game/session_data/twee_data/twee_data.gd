class_name TweeDataResource
extends Resource

var type: Global.TreeType 

var hp: float

var life_time_seconds: float
var is_large: bool

var sheet_id: int # Index of the texture from the list of possible textures

var forest_water: int # Amount of water that the current forest has... scuffed

var tech_slot: TechMenu.TechSlot

## SERIALIZING FIRE
## (Surely there's a more elegant way to do this???)
var is_on_fire: bool
var remaining_fire_lifetime: float
