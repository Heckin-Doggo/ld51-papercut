extends Node


# Declare member variables here. Examples:
var current_playing = null;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_song(song) -> void:
	var new_song = get_node_or_null(song)
	
	# dont change the song if its already playing.
	if current_playing == new_song:
		return  
	# stop the current song before switching, if ones playing
	if current_playing:
		current_playing.stop() 
	
	if new_song:
		new_song.play()
		current_playing = new_song
