extends CanvasLayer

@onready var label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label


func _ready() -> void:
	CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)
	
func on_collectible_award_received(total_award):
	label.text = str(total_award)
