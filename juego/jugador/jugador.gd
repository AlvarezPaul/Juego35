extends CharacterBody3D

@export var velocidad_correr: float = 10.0
@export var velocidad: float = 20.0
@export var fuerza_salto: float = 4.5
@export var intensidad_bob: float = 0.05
@export var velocidad_bob: float = 9.0

@export var stamina_maxima: float = 100.0
@export var consumo_stamina: float = 100.0 / 10.0
@export var regen_stamina: float = 15.0
@export var retraso_regen: float = 1.0

@export var intensidad_linterna: float = 1.0

@export var icono_linterna: Texture2D


@export var altura_llave_suelo: float = 0.064

# Herramientas en mano (llaves y ganzúa): se ponen en el mismo lugar, con el mismo
# tamaño y orientación (acostadas, dientes hacia abajo), tomando como referencia la linterna.
# Si las querés más chicas/grandes todas juntas, tocá ajuste_tamano_mano.
@export var ajuste_tamano_mano: float = 1.0
# Giro extra (grados, en X/Y/Z de la cámara) para todas por igual. 0 = como la linterna.
@export var inclinacion_herramientas: Vector3 = Vector3.ZERO

@export var distancia_tirar: float = 1.5
@export var altura_sobre_suelo: float = 0.1

@onready var pasos: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camara: Camera3D = $Cabeza/Camera3D
@onready var luz_linterna: SpotLight3D = $Cabeza/Camera3D/SpotLight3D
@onready var modelo_linterna: Node3D = $Cabeza/Camera3D/linterna
@onready var modelo_llave: Node3D = $Cabeza/Camera3D/llave
@onready var modelo_llave_reja: Node3D = $Cabeza/Camera3D/llave_reja
@onready var modelo_llave_regencia: Node3D = $Cabeza/Camera3D/llave_regencia
@onready var sonido_linterna: AudioStreamPlayer3D = $linterna
@onready var modelo_ganzua: Node3D = $Cabeza/Camera3D/ganzua

var _posicion_camara_inicial: Vector3
var _tiempo_bob: float = 0.0

var stamina: float = stamina_maxima
var _tiempo_desde_ultimo_uso: float = 0.0

var slot_actual: int = 0
var inventario_ui: Node = null

signal stamina_cambiada(actual: float, maxima: float)


func _ready() -> void:
	_posicion_camara_inicial = camara.position

	luz_linterna.light_energy = intensidad_linterna

	modelo_linterna.visible = false
	luz_linterna.visible = false
	_preparar_llave_en_mano()
	_preparar_llave_reja_en_mano()
	_preparar_llave_regencia_en_mano()
	_preparar_ganzua_en_mano()
	_igualar_herramientas_en_mano()

	call_deferred("_agregar_item_inicial")


# Caja que ocupa un modelo, medida en el espacio que define "desde"
# (es la INVERSA de la transformación del espacio en el que querés medir).
func _caja_del_modelo(modelo: Node3D, desde: Transform3D) -> AABB:
	var caja := AABB()
	var primera := true

	for nodo in modelo.find_children("*", "MeshInstance3D", true, false):
		var malla := nodo as MeshInstance3D
		if malla == null or malla.mesh == null or not malla.visible:
			continue

		var caja_malla: AABB = (desde * malla.global_transform) * malla.mesh.get_aabb()
		if primera:
			caja = caja_malla
			primera = false
		else:
			caja = caja.merge(caja_malla)

	return caja


# Caja del modelo en el espacio de la cámara (lo que ve el jugador).
func _caja_en_espacio_camara(modelo: Node3D) -> AABB:
	return _caja_del_modelo(modelo, camara.global_transform.affine_inverse())


# Deja todas las llaves y la ganzúa IGUALES en la mano:
#  - mismo tamaño que la linterna (el lado más largo mide lo mismo),
#  - mismo lugar (centradas donde está la linterna, misma altura y distancia),
#  - misma orientación que la linterna: acostadas, apuntando hacia adelante,
#    con los dientes (la parte que entra en la cerradura) mirando hacia abajo.
# La escala y rotación que tenga cada escena (.tscn) se ignora a propósito.
func _igualar_herramientas_en_mano() -> void:
	var caja_linterna := _caja_en_espacio_camara(modelo_linterna)
	if caja_linterna.size == Vector3.ZERO:
		return

	var ancla := caja_linterna.get_center()
	var tamano := caja_linterna.get_longest_axis_size() * ajuste_tamano_mano

	# [modelo, hacia dónde apunta la PUNTA, hacia dónde miran los DIENTES]
	# (las dos direcciones en el espacio propio de cada modelo)
	var herramientas := [
		[modelo_llave, Vector3.DOWN, Vector3.FORWARD],
		[modelo_llave_reja, Vector3.DOWN, Vector3.FORWARD],
		[modelo_llave_regencia, Vector3.DOWN, Vector3.FORWARD],
		[modelo_ganzua, Vector3.UP, Vector3.BACK],
	]

	for h in herramientas:
		_acomodar_en_mano(h[0] as Node3D, h[1], h[2], ancla, tamano)


# Rotación que deja el modelo acostado: la punta hacia adelante (como la linterna)
# y los dientes hacia abajo.
func _orientacion_en_mano(punta_local: Vector3, dientes_local: Vector3) -> Basis:
	var punta := punta_local.normalized()
	# Los dientes tienen que ser perpendiculares a la punta.
	var dientes := (dientes_local - punta * dientes_local.dot(punta)).normalized()

	var atras := -punta                  # la cabeza de la llave queda hacia el jugador
	var arriba := -dientes               # lo contrario de los dientes mira hacia arriba
	var lado := arriba.cross(atras)      # completa la base
	var local := Basis(lado, arriba, atras)
	var rotacion := local.transposed()   # local -> espacio cámara

	# Retoque opcional (en grados) por si querés girarlas un poco, todas por igual.
	var retoque := Basis.from_euler(inclinacion_herramientas * (PI / 180.0))
	return retoque * rotacion


func _acomodar_en_mano(
	modelo: Node3D,
	punta_local: Vector3,
	dientes_local: Vector3,
	ancla: Vector3,
	tamano: float
) -> void:
	# 1) Orientación pareja, escala 1 y centrado provisorio en el ancla, para medir el modelo.
	var rotacion := _orientacion_en_mano(punta_local, dientes_local)
	modelo.basis = rotacion
	modelo.position = ancla

	var caja := _caja_en_espacio_camara(modelo)
	var largo := caja.get_longest_axis_size()
	if largo <= 0.0001:
		return

	# 2) Escala para que mida lo mismo que la linterna y posición para que su centro caiga en el ancla.
	var factor := tamano / largo
	modelo.basis = rotacion.scaled(Vector3.ONE * factor)
	modelo.position = ancla - (caja.get_center() - ancla) * factor

func _preparar_llave_en_mano() -> void:
	var area := modelo_llave.get_node_or_null("Area3D") as Area3D
	if area != null:
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false

	var malla := modelo_llave.get_node_or_null("Area3D/Key") as MeshInstance3D
	if malla != null and malla.material_override is StandardMaterial3D:
		var material := (malla.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
		material.albedo_color = Color(1.0, 0.78, 0.2)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.72, 0.12)
		material.emission_energy_multiplier = 0.7
		malla.material_override = material

	modelo_llave.visible = false


func _preparar_llave_reja_en_mano() -> void:
	var area := modelo_llave_reja.get_node_or_null("Area3D") as Area3D
	if area != null:
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false

	var malla_reja := modelo_llave_reja.get_node_or_null("Area3D/Key") as MeshInstance3D
	if malla_reja != null and malla_reja.material_override is StandardMaterial3D:
		var material := (malla_reja.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
		material.albedo_color = Color(0.78, 0.80, 0.84)
		material.emission_enabled = true
		material.emission = Color(0.70, 0.73, 0.78)
		material.emission_energy_multiplier = 0.5
		malla_reja.material_override = material

	modelo_llave_reja.visible = false


func _preparar_llave_regencia_en_mano() -> void:
	var area := modelo_llave_regencia.get_node_or_null("Area3D") as Area3D
	if area != null:
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false

	modelo_llave_regencia.visible = false


func _hacer_visible_en_mano(modelo: Node, brillo: float = 0.8) -> void:
	for nodo in modelo.find_children("*", "MeshInstance3D", true, false):
		var malla := nodo as MeshInstance3D
		if malla == null or malla.mesh == null:
			continue

		for i in malla.mesh.get_surface_count():
			var original := malla.get_active_material(i) as StandardMaterial3D
			if original == null:
				continue

			var material := original.duplicate() as StandardMaterial3D

			var color := material.albedo_color
			color.v = max(color.v, 0.45)
			material.albedo_color = color
			material.metallic = min(material.metallic, 0.1)

			var color_brillo := color
			color_brillo.v = max(color_brillo.v, 0.7)
			material.emission_enabled = true
			material.emission = color_brillo
			material.emission_energy_multiplier = brillo

			if malla.material_override != null:
				malla.material_override = material
			else:
				malla.set_surface_override_material(i, material)


func _preparar_ganzua_en_mano() -> void:
	var area := modelo_ganzua.get_node_or_null("Area3D") as Area3D
	if area != null:
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false

	modelo_ganzua.visible = false
	

func _agregar_item_inicial() -> void:
	inventario_ui = get_tree().get_first_node_in_group("inventario")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("flashlight") and _tiene_linterna_en_mano():
		luz_linterna.visible = not luz_linterna.visible
		sonido_linterna.playing = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_alternar_slot(1)
			KEY_2:
				_alternar_slot(2)
			KEY_3:
				_alternar_slot(3)
			KEY_4:
				_alternar_slot(4)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tirar"):
		_tirar_item_equipado()


func _alternar_slot(numero: int) -> void:
	if slot_actual == numero:
		slot_actual = 0
		_actualizar_item_en_mano(0)
	else:
		slot_actual = numero
		_actualizar_item_en_mano(numero)

	if inventario_ui:
		inventario_ui.marcar_slot_equipado(slot_actual)


func _tiene_linterna_en_mano() -> bool:
	if slot_actual == 0 or inventario_ui == null:
		return false

	var item = inventario_ui.obtener_item(slot_actual)
	return item != null and item["nombre"] == "Linterna"


func _nombre_item_en_mano() -> String:
	if slot_actual == 0 or inventario_ui == null:
		return ""

	var item = inventario_ui.obtener_item(slot_actual)
	if item == null:
		return ""

	return item["nombre"]


func _actualizar_item_en_mano(_numero: int) -> void:
	var nombre := _nombre_item_en_mano()

	var es_linterna := nombre == "Linterna"
	modelo_linterna.visible = es_linterna
	
	modelo_llave.visible = (nombre == "Llave" or nombre == "Llave Salida")
	modelo_llave_reja.visible = nombre == "Llave Reja"
	modelo_ganzua.visible = nombre == "Ganzua"
	modelo_llave_regencia.visible = nombre == "Llave Regencia"
	
	if not es_linterna:
		luz_linterna.visible = false


func _tirar_item_equipado() -> void:
	if slot_actual == 0 or inventario_ui == null:
		return

	var item = inventario_ui.quitar_item(slot_actual)

	if item == null:
		return

	var escena: PackedScene = item["escena"]

	if escena != null:
		var objeto: Node3D = escena.instantiate()

		get_parent().add_child(objeto)

		var altura := altura_sobre_suelo

		if item["nombre"] in ["Llave", "Llave Salida", "Llave Reja", "Llave Regencia"]:
			var escala_suelo := 0.015
			# CORREGIDO: Se usa multiplicación de Basis en lugar de resta (-)
			var base_rotacion = Basis(Vector3.UP, global_rotation.y + PI / 2.0) * Basis(Vector3.BACK, -PI / 2.0)
			objeto.global_basis = base_rotacion.scaled(Vector3.ONE * escala_suelo)
			altura = altura_llave_suelo

		objeto.global_position = _punto_en_el_suelo(altura)

	slot_actual = 0
	_actualizar_item_en_mano(0)
	inventario_ui.marcar_slot_equipado(0)


func _punto_en_el_suelo(altura: float) -> Vector3:
	var espacio := get_world_3d().direct_space_state
	var frente := -global_transform.basis.z.normalized()

	var desde := global_position
	var hasta := desde + frente * distancia_tirar

	var consulta_pared := PhysicsRayQueryParameters3D.create(desde, hasta)
	consulta_pared.exclude = [get_rid()]
	var golpe_pared := espacio.intersect_ray(consulta_pared)

	var punto := hasta
	if not golpe_pared.is_empty():
		punto = golpe_pared.position - frente * 0.3

	var consulta_piso := PhysicsRayQueryParameters3D.create(
		punto,
		punto + Vector3.DOWN * 50.0
	)
	consulta_piso.exclude = [get_rid()]
	var golpe_piso := espacio.intersect_ray(consulta_piso)

	if golpe_piso.is_empty():
		return global_position

	return golpe_piso.position + Vector3.UP * altura

func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_procesar_salto()

	var movimiento = _procesar_movimiento(delta)

	move_and_slide()

	var corriendo := _esta_corriendo()

	_actualizar_sonido_pasos(movimiento, corriendo)
	_actualizar_head_bob(movimiento, delta, corriendo)


func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _procesar_salto() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = fuerza_salto


func _procesar_movimiento(delta: float) -> Vector3:
	var input_dir := Input.get_vector(
		"left",
		"right",
		"forward",
		"backward"
	)

	var direccion := (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var quiere_correr := (
		Input.is_action_pressed("correr")
		and direccion != Vector3.ZERO
		and is_on_floor()
	)

	var puede_correr := (
		quiere_correr
		and stamina > 0.0
	)

	var vel_actual: float

	if puede_correr:
		vel_actual = velocidad_correr
	else:
		vel_actual = velocidad

	_actualizar_stamina(puede_correr, delta)

	if direccion != Vector3.ZERO:
		velocity.x = direccion.x * vel_actual
		velocity.z = direccion.z * vel_actual
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			vel_actual
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			vel_actual
		)

	return direccion


func _esta_corriendo() -> bool:
	if not is_on_floor():
		return false

	if stamina <= 0.0:
		return false

	if not Input.is_action_pressed("correr"):
		return false

	if velocity.length() < velocidad_correr - 0.5:
		return false

	return true


func _actualizar_stamina(corriendo: bool, delta: float) -> void:
	if corriendo:
		stamina -= consumo_stamina * delta

		if stamina < 0.0:
			stamina = 0.0

		_tiempo_desde_ultimo_uso = 0.0

	else:
		_tiempo_desde_ultimo_uso += delta

		if _tiempo_desde_ultimo_uso >= retraso_regen:
			stamina += regen_stamina * delta

			if stamina > stamina_maxima:
				stamina = stamina_maxima

	stamina_cambiada.emit(stamina, stamina_maxima)


func _actualizar_sonido_pasos(
	direccion: Vector3,
	corriendo: bool
) -> void:

	var caminando := (
		direccion != Vector3.ZERO
		and is_on_floor()
	)

	if corriendo:
		pasos.pitch_scale = 1.3
	else:
		pasos.pitch_scale = 1.0

	if caminando and not pasos.playing:
		pasos.play()

	elif not caminando and pasos.playing:
		pasos.stop()


func _actualizar_head_bob(
	direccion: Vector3,
	delta: float,
	corriendo: bool
) -> void:

	if direccion != Vector3.ZERO and is_on_floor():

		var factor_bob := 1.5 if corriendo else 1.0

		_tiempo_bob += (
			delta
			* velocidad_bob
			* factor_bob
		)

		camara.position.y = (
			_posicion_camara_inicial.y
			+ sin(_tiempo_bob)
			* intensidad_bob
			* factor_bob
		)

	else:

		camara.position.y = lerp(
			camara.position.y,
			_posicion_camara_inicial.y,
			delta * 5.0
		)
