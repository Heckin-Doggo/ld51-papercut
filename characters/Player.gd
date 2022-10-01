extends KinematicBody2D

#movement stuffs
export var ACCELERATION = 20
export var FRICTION = 20
export var MOVE_SPEED = 200
export var GRAVITY = 500
export var GRAV_ACCELERATION = 20
export var JUMP_FORCE = 500
export var GRAPPLE_SHOT_SPEED = 50
#the direction of movement from player input
var input_dir = 0
#the actual velocity of the player
var velocity = Vector2(0, GRAVITY)

#if a hook is connected
var hook_connected = false
#position of connected hook
var current_hook

var Grapple = preload("res://scenes/GrappleShot.tscn")

func _physics_process(delta):
	#Gets the input direction for the players movement
	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	#handles shooting
	if Input.is_action_just_pressed("shoot"):
		#gets the direction the grapple should be fired
		var direction = self.get_global_mouse_position() - global_position
		shoot_hook(direction)
	
	if Input.is_action_just_released("shoot"):
		disconnect_hook()
	move(delta)

#calculates each individual force applied to the player, then adds them together
#for a new velocity value, then calls the move function.
func move(delta):
	var jump_value = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_value = JUMP_FORCE * -1
	
	#the direction and speed of horizontal movement
	var movement_value = move_toward(velocity.x, input_dir * MOVE_SPEED, ACCELERATION)
	#The force of gravity
	var gravity_value = move_toward(velocity.y, GRAVITY, GRAV_ACCELERATION)
	#Force from grapple hook
	var grapple_value
	if hook_connected:
		grapple_value = (current_hook.position - position) / 3
	else:
		grapple_value = Vector2.ZERO
	
	#make new velocity and add all forces together
	var new_velocity = grapple_value
	new_velocity.x = new_velocity.x + movement_value
	new_velocity.y = new_velocity.y + gravity_value
	new_velocity.y = new_velocity.y + jump_value
	#actually moves the player
	velocity = move_and_slide(new_velocity, Vector2.UP)

func shoot_hook(direction):
	var grapple = Grapple.instance()
	grapple.connect("connect", self, "connect_hook")
	grapple.set_velocity(direction.normalized() * GRAPPLE_SHOT_SPEED)
	grapple.set_position(position)
	get_parent().add_child(grapple)
	current_hook = grapple

func connect_hook():
	hook_connected = true

func disconnect_hook():
	hook_connected = false
	if current_hook != null:
		current_hook.queue_free()
		current_hook = null
