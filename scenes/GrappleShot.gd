extends KinematicBody2D

#velocity of the shot
var velocity = Vector2.ZERO
#if hook is connected to a surface
var set = false

var string

signal connect

func _ready():
	$CollisionTester.connect("body_entered", self, "set_hook")

func _physics_process(delta):
	if not set:
		move_and_collide(velocity)

func set_velocity(new_velocity):
	velocity = new_velocity
	
func set_position(new_position):
	position = new_position

func set_hook(body):
	set = true
	emit_signal("connect")
	
	
