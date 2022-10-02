extends Camera2D

onready var tween = $Tween

signal tween_finished

func _ready():
	tween.connect("tween_completed", self, "tween_done")

func move_camera(start_pos, end_pos):
	tween.interpolate_property(self, "position", start_pos, end_pos, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	current = true
	tween.start()

func tween_done(var1, var2):
	current = false
	emit_signal("tween_finished")
