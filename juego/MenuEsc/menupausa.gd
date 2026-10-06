extends Control
## Menú de pausa: se abre/cierra con Escape.
## Pausa el juego y libera el mouse al abrirse;
## reanuda y recaptura el mouse al cerrarse.

@onready var _btn_reanudar: Button = $VBoxContainer/Reanudar
@onready var _btn_salir: Button = $VBoxContainer/salir


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_btn_reanudar.pressed.connect(_reanudar)
	_btn_salir.pressed.connect(_salir_al_menu)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			_reanudar()
		else:
			_abrir()


func _abrir() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _reanudar() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _salir_al_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
