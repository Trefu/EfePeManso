# rifle.gd
class_name Rifle extends WeaponBase

@export var max_range: float = 100.0
@export var hit_effect: PackedScene

func _fire_projectile():
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin + -global_transform.basis.z * max_range
	query.exclude = [get_parent().get_parent()]  
	

	var spread_vector = Vector3(
		randf_range(-weapon_data.spread, weapon_data.spread),
		randf_range(-weapon_data.spread, weapon_data.spread),
		0
	)
	query.to += spread_vector * max_range
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_position = result.position
		var hit_normal = result.normal
		var hit_object = result.collider

		if hit_object.has_method("take_damage"):
			hit_object.take_damage(weapon_data.damage)
		
		if hit_effect:
			var effect = hit_effect.instantiate()
			get_tree().root.add_child(effect)
			effect.global_transform.origin = hit_position
			effect.look_at(hit_position + hit_normal)
