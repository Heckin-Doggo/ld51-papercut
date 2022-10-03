extends Area2D

signal clue_obtained

export var clue_name = ""
var debounce = true

func _ready():
	connect("body_entered", self, "obtain_clue")

func obtain_clue(body):
	if body.get_name() == "Player" and debounce:
		debounce = false
		emit_signal("clue_obtained", clue_name)
		$Pickup.play()
		visible = false
		yield($Pickup, "finished")
		queue_free()

func enable():
	$Sprite.visible = true
	$CollisionShape2D.call_deferred("set_disabled", false)
