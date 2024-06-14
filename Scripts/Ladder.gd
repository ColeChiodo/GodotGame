extends Area3D

func _on_body_entered(body):
	if "Player" in body.name:
		body.on_ladder = true


func _on_body_exited(body):
	if "Player" in body.name:
		body.on_ladder = false
		body.climbing = false
