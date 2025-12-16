# weapon_manager.gd
class_name WeaponManager extends Node3D

@export var weapons: Array[PackedScene] = []
@export var starting_weapon_index: int = 0

var current_weapon: WeaponBase = null
var available_weapons: Array[WeaponBase] = []
var current_weapon_index: int = 0

func _ready():
	for weapon_scene in weapons:
		var weapon = weapon_scene.instantiate() as WeaponBase
		add_child(weapon)
		weapon.visible = false
		available_weapons.append(weapon)
	
	if available_weapons.size() > starting_weapon_index:
		switch_weapon(starting_weapon_index)

func switch_weapon(index: int):
	if index < 0 or index >= available_weapons.size():
		return
	
	if current_weapon:
		current_weapon.holster()
	
	current_weapon_index = index
	current_weapon = available_weapons[index]
	current_weapon.equip()

func switch_to_next_weapon():
	var next_index = (current_weapon_index + 1) % available_weapons.size()
	switch_weapon(next_index)

func switch_to_previous_weapon():
	var prev_index = (current_weapon_index - 1) % available_weapons.size()
	switch_weapon(prev_index)

func get_current_weapon() -> WeaponBase:
	return current_weapon

func add_weapon(weapon_scene: PackedScene):
	var weapon = weapon_scene.instantiate() as WeaponBase
	add_child(weapon)
	weapon.visible = false
	available_weapons.append(weapon)

func remove_weapon(weapon_index: int):
	if weapon_index == current_weapon_index:
		switch_weapon(0)
	
	var weapon = available_weapons[weapon_index]
	available_weapons.remove_at(weapon_index)
	weapon.queue_free()
