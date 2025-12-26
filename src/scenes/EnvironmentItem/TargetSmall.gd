extends StaticBody3D

@export var max_health: float = 30.0
@export var reset_time: float = 5.0

var current_health: float = 30.0
var is_alive: bool = true
var visual_model: Node3D  
var original_rotation: Vector3
var original_position: Vector3
var hurt_sound: AudioStreamPlayer3D 

func _ready():
	var parent = get_parent()
	if not parent:
		current_health = max_health
		return
	
	var grandparent = parent.get_parent()
	if grandparent:
		visual_model = grandparent
		original_rotation = visual_model.rotation_degrees
		original_position = visual_model.position
	
	var sound_parent = get_parent()
	var sound_grandparent = sound_parent.get_parent() if sound_parent else null
	if sound_grandparent:
		hurt_sound = sound_grandparent.find_child("HurtSound", true, false) as AudioStreamPlayer3D
	
	current_health = max_health
	
func take_damage(damage: float):
	if not is_alive:
		return
	
	current_health -= damage
	
	if hurt_sound:
		hurt_sound.play()
		
	if current_health <= 0:
		die()

func die():
	if not is_alive:
		return
	
	is_alive = false
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if visual_model:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		
		tween.tween_property(visual_model, "rotation_degrees:x", 90.0, 1.0)
		tween.parallel().tween_property(visual_model, "position:y", 
		 visual_model.position.y - 1.0, 1.0)
		
		await tween.finished
		await get_tree().create_timer(reset_time).timeout
		reset_target()

func reset_target():
	if visual_model:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(visual_model, "rotation_degrees", original_rotation, 0.5)
		tween.tween_property(visual_model, "position", original_position, 0.5)
		
		await tween.finished
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
	current_health = max_health
	is_alive = true
