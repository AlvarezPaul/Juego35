extends CanvasLayer

@onready var name_input: LineEdit = $Username
@onready var boton_guardar: Button = $BotonGuardar
@onready var http_request: HTTPRequest = get_node_or_null("../HTTPRequest")

const URL_PHP := "http://localhost/juego35/guardar_puntaje.php"

func _ready() -> void:
	if http_request == null:
		push_error("No se encontró el nodo HTTPRequest en la escena sala.")
		return

	# La pantalla final y la petición deben funcionar aunque el árbol esté pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	http_request.process_mode = Node.PROCESS_MODE_ALWAYS

	if not boton_guardar.pressed.is_connected(_on_boton_guardar_pressed):
		boton_guardar.pressed.connect(_on_boton_guardar_pressed)
	if not http_request.request_completed.is_connected(_on_http_request_completed):
		http_request.request_completed.connect(_on_http_request_completed)

func _on_boton_guardar_pressed() -> void:
	Autoloadsonido.play_click()
	var nombre_jugador := name_input.text.strip_edges()

	if nombre_jugador.is_empty():
		print("Ingresá un nombre antes de guardar el puntaje.")
		return

	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		print("Ya hay una petición de guardado en curso.")
		return

	boton_guardar.disabled = true
	boton_guardar.text = "Guardando..."
	_enviar_puntaje(nombre_jugador, Cronometro.tiempo)

func _enviar_puntaje(nombre: String, tiempo: float) -> void:
	var datos := {
		"nombre": nombre,
		"tiempo": tiempo
	}
	var headers := PackedStringArray(["Content-Type: application/json"])
	var error := http_request.request(
		URL_PHP,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(datos)
	)

	if error != OK:
		print("No se pudo iniciar la petición HTTP. Código: ", error)
		_restaurar_boton()

func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_restaurar_boton()
	var respuesta := body.get_string_from_utf8()
	print("Respuesta del servidor (HTTP ", response_code, "): ", respuesta)

	if result != HTTPRequest.RESULT_SUCCESS:
		print("No se pudo conectar con el servidor. Revisá que Apache esté iniciado y que la URL sea correcta.")
		return
	if response_code != 200:
		print("El servidor devolvió el código HTTP ", response_code)
		return

	var json = JSON.parse_string(respuesta)
	if not json is Dictionary:
		print("La respuesta PHP no es un JSON válido.")
		return
	if json.get("status", "") == "success":
		boton_guardar.text = "Puntaje guardado"
		print("¡Puntaje guardado correctamente!")
	else:
		print("Error al guardar: ", json.get("message", "Error desconocido"))

func _restaurar_boton() -> void:
	boton_guardar.disabled = false
	boton_guardar.text = "Guardar puntaje"

func _on_intentar_de_nuevo_pressed() -> void:
	Autoloadsonido.play_click()
	Mensajetexto.reset_mensajes()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/pantalla_de_carga.tscn")

func _on_volver_al_menu_pressed() -> void:
	Autoloadsonido.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
