class_name Objetivos
extends CanvasLayer
## Cartel de OBJETIVO fijo, arriba a la izquierda.
##
## Cómo funciona (para entenderlo bien):
##  - PASOS es la lista de lo que hay que hacer para escapar, EN ORDEN.
##  - El cartel muestra un solo paso por vez y NO se va solo: se queda
##    hasta que el juego avisa que ese paso se cumplió.
##  - Para avisar, desde cualquier script se escribe:
##        Objetivos.completar("id_del_paso")
##    y el cartel pasa solo al paso siguiente.
##  - Si avisás un paso que ya pasó (por ejemplo abrir de nuevo la puerta),
##    no pasa nada. Así no se rompe el orden.

# Acá cambiás los textos cuando quieras. El "id" es el nombre que usan los
# otros scripts para avisar que ese paso está cumplido.
const PASOS := [
	{"id": "encontrar_ganzua",
	 "texto": "Te quedaste encerrado en el baño. Tenés que encontrar algo para salir."},
	{"id": "abrir_banio",
	 "texto": "Encontraste algo que puede servirte. Usalo para abrir la puerta."},
	{"id": "buscar_llave_cantina",
	 "texto": "Hay algo en la cantina que puede servirte. Andá a buscarlo."},
	{"id": "ir_regencia",
	 "texto": "Encontraste una llave. Andá a regencia a ver qué podés encontrar."},
	{"id": "buscar_llave_reja",
	 "texto": "Revisá bien la regencia: tiene que haber algo más que te ayude a escapar."},
	{"id": "abrir_reja",
	 "texto": "Tenés la llave de la reja. Encontrála y abrila."},
	{"id": "salir",
	 "texto": "La reja está abierta. ¡Salí de la escuela!"},
]

# Estas variables son "static": son de la clase y no de un cartel en
# particular, por eso se pueden usar desde cualquier lado como Objetivos.algo
static var paso_actual: int = -1
static var hud: Objetivos = null

var _panel: PanelContainer
var _texto: Label


# --- Funciones para usar desde otros scripts ---------------------------------

# La llama la sala al empezar la partida (crea el cartel y muestra el paso 1).
static func iniciar(escena: Node) -> void:
	paso_actual = 0
	hud = Objetivos.new()
	escena.add_child(hud)


# "Este paso ya está cumplido": el cartel muestra el siguiente.
static func completar(id: String) -> void:
	for i in PASOS.size():
		if PASOS[i]["id"] == id:
			if i >= paso_actual:
				paso_actual = i + 1
				if is_instance_valid(hud):
					hud._mostrar_paso()
			return
	push_warning("Objetivos: no existe el paso '" + id + "'")


# Esconde el cartel para siempre (se usa cuando el jugador escapa).
static func ocultar() -> void:
	paso_actual = PASOS.size()
	if is_instance_valid(hud):
		hud._mostrar_paso()


# --- Dibujo del cartel ------------------------------------------------------

func _ready() -> void:
	layer = 5  # debajo del menú de pausa (que usa layer 10)
	_crear_cartel()
	_mostrar_paso()


func _crear_cartel() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(16, 52)  # arriba a la izquierda, debajo de los FPS
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# El fondo y el borde del cuadro
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0, 0, 0, 0.7)
	estilo.border_color = Color(0, 0, 0)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(8)
	estilo.set_content_margin_all(14)
	_panel.add_theme_stylebox_override("panel", estilo)

	var caja := VBoxContainer.new()
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(caja)

	# Misma fuente que usa el resto del juego (si no la encuentra, usa la normal)
	var fuente: Font = null
	if ResourceLoader.exists("res://Fuentes/trebuc.ttf"):
		fuente = load("res://Fuentes/trebuc.ttf")

	var titulo := Label.new()
	titulo.text = "OBJETIVO"
	titulo.add_theme_font_size_override("font_size", 16)
	titulo.add_theme_color_override("font_color", Color(255, 255, 255))
	if fuente != null:
		titulo.add_theme_font_override("font", fuente)
	caja.add_child(titulo)

	_texto = Label.new()
	_texto.custom_minimum_size = Vector2(340, 0)  # ancho fijo: el texto baja de renglón
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.add_theme_font_size_override("font_size", 20)
	if fuente != null:
		_texto.add_theme_font_override("font", fuente)
	caja.add_child(_texto)

	add_child(_panel)


func _mostrar_paso() -> void:
	if paso_actual < 0 or paso_actual >= PASOS.size():
		_panel.hide()
		return
	_texto.text = PASOS[paso_actual]["texto"]
	_panel.show()
	# Pequeño fundido para que se note que cambió el objetivo
	_panel.modulate.a = 0.0
	create_tween().tween_property(_panel, "modulate:a", 1.0, 0.4)
