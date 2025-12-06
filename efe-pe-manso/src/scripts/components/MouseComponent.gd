extends Node
class_name MouseComponent

var head: Node3D
var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()
	head = player.get_node("%head")

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
		player.rotate_y(deg_to_rad(-event.relative.x * GameConfig.player_mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * GameConfig.player_mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
