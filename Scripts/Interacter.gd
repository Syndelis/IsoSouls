extends Area



func _on_Interacter_body_entered(body):
	if body.is_in_group("Interactable"):
		body.prompt(true)


func _on_Interacter_body_exited(body):
	if body.is_in_group("Interactable"):
		body.prompt(false)
