extends CharacterBody3D

@export var look_sensitivity : float = 0.006

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%CharacterHeadCamera.rotate_x(event.relative.y * look_sensitivity)
			%CharacterHeadCamera.rotation.x = clamp(%CharacterHeadCamera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(_delta: float) -> void:
	pass

func _process(_delta: float) -> void:
	pass
