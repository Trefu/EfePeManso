extends Camera3D

const MOUSE_SENSITIVITY: float = 0.06
var head: Node3D

@onready var player = find_parent("PlayerFinal") as Player
@onready var camera: Camera3D = self

func _process(_delta: float) -> void:
	pass

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
		player.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		var rot_x = camera.rotation_degrees.x - event.relative.y * MOUSE_SENSITIVITY
		rot_x = clamp(rot_x, -89, 89)
		camera.rotation_degrees.x = rot_x
