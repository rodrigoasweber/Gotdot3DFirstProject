extends Node3D


var camroot_horiz:float = 0
var horiz_sensitivity:float = 0.1
var horiz_acceleration:float = 10.0

var camroot_vert:float = 0
var vert_sensitivity:float = 0.1
var vert_acceleration:float = 10.0
@export var camroot_vert_max:int = 75
@export var camroot_vert_min:int = -55

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camroot_horiz += -event.relative.x * horiz_sensitivity
		camroot_vert += event.relative.y * vert_sensitivity
		
func _physics_process(delta: float) -> void:
	camroot_vert = clamp(camroot_vert, deg_to_rad(camroot_vert_min), deg_to_rad(camroot_vert_max))
	get_node("horizontal_mov").rotation.y = lerpf(get_node("horizontal_mov").rotation.y, camroot_horiz, delta*horiz_acceleration)
	get_node("horizontal_mov/vertical_mov").rotation.x = lerpf(get_node("horizontal_mov/vertical_mov").rotation.x, camroot_vert, delta*vert_acceleration)
