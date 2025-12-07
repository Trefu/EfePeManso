extends Node
class_name AnimationComponent

@export var animation_tree: AnimationTree
@export var blend_space_path: String = "parameters/Strafe/blend_position"

var character: CharacterBody3D

func _ready():
	character = get_parent() as CharacterBody3D
	if animation_tree:
		animation_tree.active = true

func update_from_movement(velocity: Vector3, _is_on_floor: bool, _is_dashing: bool):
	if not animation_tree or not character:
		return
	
	# 1. Velocidad ya está en espacio GLOBAL (así funciona Godot)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var speed = horizontal_velocity.length()
	
	# 2. Si no se mueve, idle
	if speed < 0.1:
		animation_tree.set(blend_space_path, Vector2.ZERO)
		return
	
	# 3. Obtener hacia dónde mira el personaje (en espacio global)
	#    ¡IMPORTANTE! La velocidad ya es global, solo necesitamos comparar
	var character_forward = -character.global_transform.basis.z.normalized()
	var character_right = character.global_transform.basis.x.normalized()
	
	# 4. ¿Qué porcentaje de la velocidad va hacia adelante/derecha?
	var forward_amount = horizontal_velocity.normalized().dot(character_forward)
	var right_amount = horizontal_velocity.normalized().dot(character_right)
	
	# 5. Crear vector para BlendSpace2D
	var blend_position = Vector2(right_amount, forward_amount)  # X=derecha, Y=adelante
	
	# 6. Aplicar al AnimationTree
	animation_tree.set(blend_space_path, blend_position)
	
	# Debug
	print("Velocity: {horizontal_velocity.normalized()}")
	print("Forward: {character_forward}, Right: {character_right}")
	print("Blend: {blend_position}")
