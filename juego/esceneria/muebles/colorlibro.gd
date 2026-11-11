extends Node3D

@export var color_base: Color = Color(0.3, 0.5, 0.8) # Elige tu color base aquí

func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			# Crear un nuevo material único para cada objeto
			var material = StandardMaterial3D.new()
			
			# Generar un tono distinto variando ligeramente la luminosidad u oscuridad
			var factor_tono = randf_range(0.6, 1.4) 
			material.albedo_color = Color(
				clamp(color_base.r * factor_tono, 0.0, 1.0),
				clamp(color_base.g * factor_tono, 0.0, 1.0),
				clamp(color_base.b * factor_tono, 0.0, 1.0)
			)
			
			# Aplicar el material directamente al objeto
			child.material_override = material
