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
#the string connecting the hook
var string

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
		grapple_value = (current_hook.position - position).normalized() * 75
	else:
		grapple_value = Vector2.ZERO
	
	#make new velocity and add all forces together
	var new_velocity = grapple_value
	new_velocity.x = new_velocity.x + movement_value
	new_velocity.y = new_velocity.y + gravity_value
	new_velocity.y = new_velocity.y + jump_value
	#actually moves the player
	velocity = move_and_slide(new_velocity, Vector2.UP)

#Shoots a grappling hook projectile and connects it to the player
func shoot_hook(direction):
	#make the object
	var grapple = Grapple.instance()
	#connect functions for when projectile connects to a surface
	grapple.connect("connect", self, "connect_hook")
	grapple.connect("break_line", self, "disconnect_hook")
	#set projectiles position and velocity
	grapple.set_velocity(direction.normalized() * GRAPPLE_SHOT_SPEED)
	grapple.set_position(position)
	grapple.set_player(self)
	#place projectile in the world
	get_parent().add_child(grapple)
	#let player know the current hook
	current_hook = grapple

#Lets player know the current hook is connected to a surface
func connect_hook():
	hook_connected = true

#Disconnects the current hook
func disconnect_hook():
	#tells player that no hook is connected
	hook_connected = false
	#deletes the old hook
	if current_hook != null:
		current_hook.queue_free()
		current_hook = null

func activate_camera():
	$Camera2D.current = true
