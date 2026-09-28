extends RayCast3D

func _process(delta):
	if is_colliding():
		# obtiene la informacion del objeto que esta collision el raycast
		var hitObj = get_collider()
		# si el objeto golpeado no tiene interact(), busca en sus padres
		# (por ejemplo, la puerta tiene varios StaticBody3D hijos para el marco
		# que no tienen el script, pero su padre "modelo" si lo tiene)
		while hitObj != null && !hitObj.has_method("interact"):
			hitObj = hitObj.get_parent()
		if hitObj != null && hitObj.has_method("interact") && Input.is_action_just_pressed("interaccion"):
			hitObj.interact()
