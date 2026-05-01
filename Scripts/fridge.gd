extends Area2D

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# Si el mozo viene con un pedido de bebida, la heladera se la da al instante
	if waiter.actual_state == waiter.HandState.DRINK_ORDER:
		print("Heladera: Bebida lista.")
		
		# Cambiamos lo que tiene en las manos
		waiter.actual_state = waiter.HandState.DRINK
		
		# IMPORTANTE: NO borramos waiter.active_table porque el mozo 
		# todavía necesita recordar a qué mesa llevarle esta bebida.
	else:
		print("Acción no válida en la heladera.")
