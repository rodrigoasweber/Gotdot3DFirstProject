extends CharacterBody3D

@onready var animation_tree = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var player_mesh = get_node("Knight")

@export var gravity:float = 9.8
@export var jump_force:int = 9
@export var walk_speed:int = 3
@export var run_speed: int = 10

#animation node names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attack_one_node_name: String = "Attack_one"
var death_node_name: String = "Death"

#State machine conditions
var is_attacking: bool
var is_walking: bool
var is_running: bool
var is_dying: bool

#physiscs values
var direction: Vector3
var horiz_velocity: Vector3
var aim_turn: float
var movement: Vector3
var vert_velocity: Vector3
var movement_speed: int
var angular_acceleration: int
var acceleration: float
var just_hit: bool

@onready var camroot_horiz = get_node("camera_root/horizontal_mov")

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x*0.015
	if event.is_action_pressed("aim"):
		direction = camroot_horiz.global_transform.basis.z
		
func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	if !is_dying:
		attackOne()
		if !on_floor:
			vert_velocity += Vector3.DOWN*gravity*2*delta
		else:
			vert_velocity = Vector3.DOWN*gravity/10
		if Input.is_action_just_pressed("jump") and !is_attacking and on_floor:
			vert_velocity = Vector3.UP*jump_force
		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15
		if (attack_one_node_name in playback.get_current_node()):
			is_attacking = true
		else:
			is_attacking = false
		var horiz_rotation = camroot_horiz.global_transform.basis.get_euler().y
		if (Input.is_action_pressed("forward") || 
			Input.is_action_pressed("backward") || 
			Input.is_action_pressed("left") || 
			Input.is_action_pressed("right")):
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"), 
								0,
								Input.get_action_strength("forward") - Input.get_action_strength("backward"))
			direction = direction.rotated(Vector3.UP, horiz_rotation).normalized()
			if Input.is_action_pressed("sprint") and is_walking:
				movement_speed = run_speed
				is_running = true
			else:
				movement_speed = walk_speed
				is_walking = true
		else:
			is_walking = false
			is_running = false
		if Input.is_action_pressed("aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, 
												camroot_horiz.rotation.y, 
												delta*angular_acceleration)
		else:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, 
												atan2(direction.x, direction.z) - rotation.y,
												delta*angular_acceleration)
		
		if is_attacking:
			horiz_velocity = horiz_velocity.lerp(direction.normalized()*0.1, acceleration*delta)
		else:
			horiz_velocity = horiz_velocity.lerp(direction.normalized()*movement_speed, acceleration*delta)
		velocity.z = horiz_velocity.z + vert_velocity.z
		velocity.x = horiz_velocity.x + vert_velocity.x
		velocity.y = vert_velocity.y
		move_and_slide()
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = !on_floor
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = !is_running
	animation_tree["parameters/conditions/is_dying"] = is_dying
	
func attackOne() -> void:
	if (idle_node_name in playback.get_current_node()) || (walk_node_name in playback.get_current_node()) || (run_node_name in playback.get_current_node()):
		if Input.is_action_just_pressed("attack"):
			if !is_attacking:
				playback.travel(attack_one_node_name)
