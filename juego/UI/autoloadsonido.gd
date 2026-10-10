extends Node

var boom = preload("res://UI/sonidoboom.mp3")
var click = preload("res://UI/click.mp3")
var player = AudioStreamPlayer.new()

func _ready():
	add_child(player)

func play_click():
	player.stream = click
	player.play()

func jugar_click():
	player.stream = boom
	player.play()
