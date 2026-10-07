extends Control
@onready var conf: Control = $"."

func _on_si_pressed() -> void:
	Autoloadsonido.play_click()
	conf.visible = false
	get_tree().paused=false
	get_tree().change_scene_to_file("res://UI/Menu.tscn")

func _on_no_pressed() -> void:
	Autoloadsonido.play_click()
	conf.visible = false
