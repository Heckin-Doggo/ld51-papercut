extends Control


# Declare member variables here. Examples:
onready var Music = get_node("/root/Music")


# Called when the node enters the scene tree for the first time.
func _ready():
	Music.change_song("Slow")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://cutscenes/IntroCutscene.tscn")
