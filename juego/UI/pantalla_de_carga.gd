extends Control

@onready var texto: Label = $Consejos
@onready var contador: Timer = $PdC
@onready var barra: ProgressBar = $ProgressBar

var progreso: Array = []
var estado_de_carga: int
var ultimo_consejo: String = ""
var consejos: Array[String] = [
	"Consejo: algo", "Consejo: algo2", "Consejo: algo3", "Consejo: algo4", "Consejo: algo5"]


func _ready() -> void:
	imprimir_texto()
	contador.timeout.connect(_on_timer_timeout)

	# Empieza a cargar la escena en segundo plano.
	# La escena a cargar está en el autoload PantallaDeCarga (autoloadpcarga.gd).
	var error := ResourceLoader.load_threaded_request(PantallaDeCarga.change_scene)
	if error != OK:
		push_error("No se pudo empezar a cargar: " + PantallaDeCarga.change_scene)
		set_process(false)


func _process(_delta: float) -> void:
	estado_de_carga = ResourceLoader.load_threaded_get_status(PantallaDeCarga.change_scene, progreso)

	match estado_de_carga:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progreso.size() > 0:
				barra.value = progreso[0] * 100

		ResourceLoader.THREAD_LOAD_LOADED:
			barra.value = 100
			set_process(false)
			var escena: PackedScene = ResourceLoader.load_threaded_get(PantallaDeCarga.change_scene)
			get_tree().call_deferred("change_scene_to_packed", escena)

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			# Si la carga falla, avisamos en vez de quedarnos trabados sin saber por qué.
			push_error("No se pudo cargar la escena: " + PantallaDeCarga.change_scene)
			set_process(false)


# Cada 3 segundos se cambia el consejo.
func _on_timer_timeout() -> void:
	imprimir_texto()
	contador.start()


# Elige un consejo al azar (distinto al anterior).
func imprimir_texto() -> void:
	if consejos.is_empty():
		return

	var nuevo: String = consejos.pick_random()
	while consejos.size() > 1 and nuevo == ultimo_consejo:
		nuevo = consejos.pick_random()

	ultimo_consejo = nuevo
	texto.text = nuevo
