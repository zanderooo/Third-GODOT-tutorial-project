extends Node

@export var node_finite_state_machine : NodeFiniteStateMachine

func _on_attackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		node_finite_state_machine.transition_to("attack")


func _on_attackarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		node_finite_state_machine.transition_to("idle")
