extends Node3D

func _ready():
	# 1. Paleta con una mezcla de colores más vivos y variados (sin ser exclusivamente oscuros)
	var paleta_biblioteca = [
		Color("#c93b2b"), # Rojo vivo
		Color("#2b6fc9"), # Azul brillante
		Color("#c98a2b"), # Naranja / Ocre
		Color("#2bc95e"), # Verde claro
		Color("#8b2bc9"), # Púrpura / Morado
		Color("#c92b94"), # Magenta / Rosa oscuro
		Color("#2bc9b8"), # Turquesa
		Color("#b8c92b")  # Lima / Amarillo verdoso
	]
	
	# Obtener todos los hijos que sean MeshInstance3D (los lomos de los libros)
	var libros = []
	for child in get_children():
		if child is MeshInstance3D:
			libros.append(child)
			
	if libros.size() == 0:
		return

	# 2. Variables para simular colecciones de libros en la balda
	var color_coleccion_actual = paleta_biblioteca[randi() % paleta_biblioteca.size()]
	var libros_en_esta_coleccion = 0
	var limite_coleccion = randi() % 4 + 3 # Bloques de 3 a 6 libros de la misma colección
	
	for i in range(libros.size()):
		var material = StandardMaterial3D.new()
		
		# Si se acabó el bloque actual, elegimos un nuevo color base para la siguiente colección
		if libros_en_esta_coleccion >= limite_coleccion:
			color_coleccion_actual = paleta_biblioteca[randi() % paleta_biblioteca.size()]
			limite_coleccion = randi() % 4 + 3
			libros_en_esta_coleccion = 0
		
		libros_en_esta_coleccion += 1
		
		# 3. Variación de tono suave para mantener la armonía dentro de la misma colección
		var variacion_sutil = randf_range(0.85, 1.15)
		
		material.albedo_color = Color(
			clamp(color_coleccion_actual.r * variacion_sutil, 0.0, 1.0),
			clamp(color_coleccion_actual.g * variacion_sutil, 0.0, 1.0),
			clamp(color_coleccion_actual.b * variacion_sutil, 0.0, 1.0)
		)
		
		# Mantener un acabado mate (rugosidad) para que no parezca plástico brillante
		material.roughness = 0.8
		
		# Asignar el material único al libro
		libros[i].material_override = material
