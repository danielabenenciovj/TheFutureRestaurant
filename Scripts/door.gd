extends Node2D

# Creamos nuestra propia señal que enviará la posición exacta donde debe aparecer el cliente
signal customer_ready_to_spawn(spawn_position: Vector2)

func open_door() -> void:
	print("La puerta se está abriendo...")
	
	# FUTURO: Acá vas a poner algo como $AnimationPlayer.play("abrir_puerta")
	
	# PRESENTE: Simulamos el tiempo de la animación pausando el código medio segundo
	await get_tree().create_timer(0.5).timeout 
	
	print("Puerta abierta. Avisando al nivel que puede spawnear al cliente.")
	
	# Emitimos la señal y le pasamos la posición del Marker2D
	customer_ready_to_spawn.emit($SpawnPoint.global_position)
	
	# FUTURO: Acá vas a poner algo como $AnimationPlayer.play("cerrar_puerta")
