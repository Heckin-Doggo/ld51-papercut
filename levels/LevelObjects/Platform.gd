extends StaticBody2D

func _ready():
	$Sprite.visible = false
	$CollisionShape2D.disabled = true

func enable():
	$Sprite.visible = true
	$CollisionShape2D.call_deferred("set_disabled", false)
