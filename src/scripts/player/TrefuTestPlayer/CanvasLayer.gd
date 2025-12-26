extends CanvasLayer

@onready var trefu_test_player: CharacterBody3D = $".."

func _ready():
	await get_tree().process_frame
	_connect_to_weapon()
	if trefu_test_player:
		var weapon = trefu_test_player.get_node("Head/WeaponHolder").get_child(0)
		if weapon:
			weapon.ammo_changed.connect(_update_ammo_display)


func _update_ammo_display(current: int, max_ammo: int):
	$Control/AmmoLabel.text = 'Current ammo '+ str(current) + "/" + str(max_ammo)
	$Control/AmmoLabel.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Control/AmmoLabel.modulate = Color.WHITE


func _connect_to_weapon():
	if trefu_test_player:
		var weapon_holder = trefu_test_player.get_node_or_null("Head/WeaponHolder")
		if weapon_holder and weapon_holder.get_child_count() > 0:
			var weapon = weapon_holder.get_child(0)
			if weapon.has_signal("ammo_changed"):
				print("Conectado a señal ammo_changed")
				
				# Establecer valores iniciales
				_update_ammo_display(weapon.current_ammo, weapon.weapon_data.magazine_size)
			else:
				print("ERROR: El arma no tiene señal ammo_changed")
		else:
			print("ERROR: No se encontró WeaponHolder o no tiene hijos")
	else:
		print("ERROR: No se encontró el jugador")
