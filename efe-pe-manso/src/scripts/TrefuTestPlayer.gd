extends CharacterBody3D

#region Components
@onready var mouse_component: MouseComponent = $MouseComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var jump_component: JumpComponent = $JumpComponent
@onready var gravity_component: GravityComponent = $GravityComponent
@onready var dash_component: DashComponent = $DashComponent
#endregion

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#region Physics Processing
func _physics_process(delta: float) -> void:
	# Procesar gravedad
	gravity_component.handle_gravity(delta)
	
	# Procesar dash
	dash_component.handle_dash(delta)
	
	# Procesar movimiento (solo si no está haciendo dash)
	if not dash_component.isDashing:
		movement_component.handle_movement(delta)
		
	# Procesar salto
	jump_component.handle_jump()
	
	# Aplicar física
	move_and_slide()
#endregion
