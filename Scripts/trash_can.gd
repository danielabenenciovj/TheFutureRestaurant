extends Area2D

# Podés cambiar de cuánto es la multa desde el Inspector
@export var penalty_amount: int = 50 


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# Verificamos si tiene comida lista o una bebida para tirar
	if waiter.actual_state == waiter.HandState.DISH_READY or waiter.actual_state == waiter.HandState.DRINK:
		print("¡Comida/Bebida tirada a la basura! Multa de $", penalty_amount)
		
		# 1. Le vaciamos las manos
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.current_item_texture = null
		waiter.active_table = null 
		
		# 2. Aplicamos la multa buscando la UI
		var ui = get_tree().get_first_node_in_group("UI_GROUP")
		if ui: 
			# Pasamos el número en negativo para que reste
			ui.Add_Money(-penalty_amount)
			
	# Opcional: Permitirle tirar platos sucios por si se traba, pero sin multa
	elif waiter.actual_state == waiter.HandState.DIRTY_DISH:
		print("Plato sucio tirado a la basura.")
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.current_item_texture = null
		waiter.active_table = null 
		
	else:
		print("El mozo tiene las manos vacías o solo lleva una comanda (papel). No hay nada que tirar.")
