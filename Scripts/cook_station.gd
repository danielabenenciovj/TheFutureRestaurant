extends Area2D

var is_cooking: bool = false
var is_food_ready: bool = false
var orders_queue: Array[Area2D] = []
var table_waiting_for_this_dish: Area2D = null

@onready var cook_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var waiters = get_tree().get_first_node_in_group("Waiters")
		
		if waiters != null:
		
			waiters.nav_agent.target_position = global_position
			
		
			waiters.target_interactable = self
			
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# El mesero DEJA una orden (No importa si la cocina ya está cocinando)
	if waiter.actual_state == waiter.HandState.FOOD_ORDER:
		print("Cocina recibe comanda. Añadida a la cola.")
		
		# Agregamos la orden (la mesa) al final de la lista
		orders_queue.append(waiter.active_table)
		
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null
		
		# Si la cocina no estaba haciendo nada y no hay comida estorbando, arranca a cocinar
		check_and_cook()
		
	# El mesero RETIRA un plato listo
	elif waiter.actual_state == waiter.HandState.EMPTY and is_food_ready:
		print("Mesero retira el plato de la mesa ", table_waiting_for_this_dish.name)
		waiter.actual_state = waiter.HandState.DISH_READY
		waiter.active_table = table_waiting_for_this_dish
		
		is_food_ready = false
		table_waiting_for_this_dish = null 
		
		# Al liberar la mesada, nos fijamos si hay más comandas esperando para arrancar otra vez
		check_and_cook()
		
	elif is_cooking:
		print("La cocina está procesando pedidos. Quedan ", orders_queue.size(), " en cola.")
	else:
		print("Acción no válida en la cocina.")

# Función auxiliar para ver si podemos arrancar a cocinar algo de la lista
func check_and_cook() -> void:
	# Si ya estoy cocinando, o tengo un plato listo ocupando espacio, o no hay comandas, no hago nada
	if is_cooking or is_food_ready or orders_queue.size() == 0:
		return
		
	print("Empezando a cocinar la siguiente comanda...")
	is_cooking = true
	
	# Sacamos la primera orden de la lista y nos la guardamos
	table_waiting_for_this_dish = orders_queue.pop_front()
	
	cook_timer.start()

func _on_timer_timeout() -> void:
	is_cooking = false
	is_food_ready = true
	print("La comida está lista para ser retirada.")
