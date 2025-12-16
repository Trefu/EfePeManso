class_name WeaponBase extends Node3D

signal weapon_fired(weapon_data: WeaponData)
signal weapon_reloaded(weapon_data: WeaponData)
signal ammo_changed(current: int, reserve: int)
signal weapon_equipped
signal weapon_holstered

@export var weapon_data: WeaponData
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle: Marker3D = $Muzzle
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var is_reloading: bool = false
var can_fire: bool = true
var fire_timer: Timer

func _ready():
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_cooldown_end)
	
	if weapon_data and weapon_data.mesh:
		var mesh_instance = weapon_data.mesh.instantiate()
		add_child(mesh_instance)

func primary_action():
	if not can_fire or is_reloading or weapon_data.current_ammo <= 0:
		return false
	
	weapon_data.current_ammo -= 1
	emit_signal("ammo_changed", weapon_data.current_ammo, weapon_data.reserve_ammo)
	
	_fire_projectile()
	
	if weapon_data.shoot_sound:
		audio_player.stream = weapon_data.shoot_sound
		audio_player.play()
	
	if animation_player.has_animation("fire"):
		animation_player.play("fire")
	
	can_fire = false
	fire_timer.start(weapon_data.fire_rate)
	
	emit_signal("weapon_fired", weapon_data)
	return true

func secondary_action():
	pass

func reload():
	if is_reloading or weapon_data.current_ammo == weapon_data.magazine_size:
		return false
	
	if weapon_data.reserve_ammo <= 0:
		return false
	
	is_reloading = true
	
	if animation_player.has_animation("reload"):
		animation_player.play("reload")
	
	if weapon_data.reload_sound:
		audio_player.stream = weapon_data.reload_sound
		audio_player.play()
	
	await get_tree().create_timer(weapon_data.reload_time).timeout
	
	var ammo_needed = weapon_data.magazine_size - weapon_data.current_ammo
	var ammo_to_reload = min(ammo_needed, weapon_data.reserve_ammo)
	
	weapon_data.current_ammo += ammo_to_reload
	weapon_data.reserve_ammo -= ammo_to_reload
	
	is_reloading = false
	emit_signal("weapon_reloaded", weapon_data)
	emit_signal("ammo_changed", weapon_data.current_ammo, weapon_data.reserve_ammo)
	
	return true

func _fire_projectile():
	# Este método es para ser sobrescrito por armas específicas
	pass

func _on_fire_cooldown_end():
	can_fire = true

func equip():
	visible = true
	emit_signal("weapon_equipped")

func holster():
	visible = false
	emit_signal("weapon_holstered")
