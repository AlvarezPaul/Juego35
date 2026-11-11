extends Node3D

func _ready():
	# 1. Definimos los colores base del arcoíris en formato hexadecimal o RGB
	var colores_arcoiris = [
		Color("#FF0000"), # Rojo
		Color("#FF7F00"), # Naranja
		Color("#FFFF00"), # Amarillo
		Color("#00FF00"), # Verde
		Color("2fbaffff"), # Azul
	]
	
	# 2. Elegimos uno de los colores del arcoíris de forma totalmente aleatoria
	colores_arcoiris.shuffle()
	var color_elegido = colores_arcoiris[0]
	
	# Imprimimos en la consola de Godot cuál color salió elegido
	print("Color base seleccionado al azar (RGB): ", color_elegido)
	
	# 3. Recorremos todos los objetos hijos para aplicarles tonos distintos del color elegido
	for child in get_children():
		if child is MeshInstance3D:
			var material = StandardMaterial3D.new()
			
			# Generamos un factor aleatorio para variar la luminosidad (crear distintos tonos)
			# Un valor entre 0.5 (más oscuro) y 1.4 (más claro)
			var factor_tono = randf_range(0.5, 1.4)
			
			# Aplicamos el factor manteniendo la esencia del color base
			material.albedo_color = Color(
				clamp(color_elegido.r * factor_tono, 0.0, 1.0),
				clamp(color_elegido.g * factor_tono, 0.0, 1.0),
				clamp(color_elegido.b * factor_tono, 0.0, 1.0)
			)
			
			# Asignamos el material único al objeto
			child.material_override = material
