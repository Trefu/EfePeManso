extends CharacterBody3D

#region Components
@onready var mouse_component: MouseComponent = $MouseComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var jump_component: JumpComponent = $JumpComponent
@onready var gravity_component: GravityComponent = $GravityComponent
@onready var dash_component: DashComponent = $DashComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
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
	update_animation()
#endregion

func update_animation():
	if animation_component:
		animation_component.update_from_movement(
			velocity,
			is_on_floor(),
			false  # is_dashing - ajusta según tu dash component
		)
