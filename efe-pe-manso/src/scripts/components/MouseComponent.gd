extends Node
class_name MouseComponent

@export var aim_sensitivity: float = 0.2
var head: Node3D
var character: CharacterBody3D

func _ready():
	character = get_parent()
	head = character.get_node("%head")

func _unhandled_input(event: InputEvent):
	# ESC para liberar mouse	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Click para recapturar
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		character.rotate_y(deg_to_rad(-event.relative.x * aim_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * aim_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
