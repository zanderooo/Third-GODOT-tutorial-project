extends Node2D

@export var heart1 : Texture2D
@export var heart0 : Texture2D

@onready var heart1_1 = $heart1
@onready var heart1_2 = $heart2
@onready var heart1_3 = $heart3

func _ready():
	HealthManager.on_health_changed.connect(on_player_health_changed)

func on_player_health_changed(player_current_health):
	if player_current_health == 3:
		heart1_3.texture = heart1
	elif player_current_health < 3:
		heart1_3.texture = heart0
	if player_current_health == 2:
		heart1_2.texture = heart1
	elif player_current_health < 2:
		heart1_2.texture = heart0
	if player_current_health == 1:
		heart1_1.texture = heart1
	elif player_current_health < 1:
		heart1_1.texture = heart0
