extends KinematicBody2D

#velocity of the shot
var velocity = Vector2.ZERO
#if hook is connected to a surface
var set = false

var player

var string

signal connect

func _ready():
	$CollisionTester.connect("body_entered", self, "set_hook")
	string = $Line2D
	string.add_point(position)
	string.add_point(position)

func _physics_process(delta):
	if not set:
		move_and_collide(velocity)

func _process(delta):
	if player != null:
		string.set_point_position(0, player.global_position - position)
	string.set_point_position(1, global_position - position)

func set_velocity(new_velocity):
	velocity = new_velocity
	
func set_position(new_position):
	position = new_position

func set_hook(_body):
	set = true
	emit_signal("connect")
	
func set_player(new_player):
	player = new_player
