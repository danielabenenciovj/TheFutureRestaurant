extends Node2D

signal customer_ready_to_spawn(spawn_position: Vector2)

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func open_door() -> void:
	print("La puerta se está abriendo...")
	# 1. Reproducimos la animación de abrir
	anim_sprite.play("open")
	
	# 2. Pausamos el script hasta que termine de abrirse
	await anim_sprite.animation_finished
	
	print("Puerta abierta. Avisando al nivel que puede spawnear al cliente.")
	
	# 3. Emitimos tu señal como ya lo venías haciendo
	customer_ready_to_spawn.emit($SpawnPoint.global_position)
	
	# 4. Le damos medio segundo de gracia para que el cliente camine fuera del marco
	await get_tree().create_timer(0.5).timeout 
	
	# 5. Cerramos la puerta
	anim_sprite.play("close")
	
	# 6. Esperamos que termine de cerrar para dejarla en reposo
	await anim_sprite.animation_finished
	anim_sprite.play("idle")
