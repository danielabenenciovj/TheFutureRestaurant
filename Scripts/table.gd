extends Area2D

var is_occupied: bool = false
var has_customer_waiting: bool = false
var is_waiting_for_food: bool = false
var is_eating: bool = false
var has_dirty_dish: bool = false

var current_customer: CharacterBody2D = null

@onready var eat_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var waiters = get_tree().get_first_node_in_group("Waiters")
		
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# CASO 1: Tomar la orden
	if waiter.actual_state == waiter.HandState.EMPTY and has_customer_waiting:
		waiter.actual_state = waiter.HandState.ORDER
		waiter.active_table = self # NUEVO: El mesero anota que esta orden es de esta mesa
		
		has_customer_waiting = false
		is_waiting_for_food = true
		print("Orden tomada. La mesa espera su comida.")
		
	# CASO 2: Entregar la comida
	# NUEVO: Ahora además verificamos que el plato que trae sea para ESTA mesa
	elif waiter.actual_state == waiter.HandState.DISH_READY and is_waiting_for_food and waiter.active_table == self:
		print("¡Plato correcto entregado!")
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null # NUEVO: El mesero borra la etiqueta porque ya cumplió
		
		is_waiting_for_food = false
		is_eating = true
		eat_timer.start()
		
	# CASO 3: Recoger plato sucio (Acá no importa de quién era)
	elif waiter.actual_state == waiter.HandState.EMPTY and has_dirty_dish:
		print("Mesero recogió el plato sucio.")
		waiter.actual_state = waiter.HandState.DIRTY_DISH
		has_dirty_dish = false
		is_occupied = false 
		var ui = get_tree().get_first_node_in_group("UI_GROUP")
		if ui:
			ui.Add_Money(100)
			print("Plata entregada con éxito")
		else:
			print("Error: No encontré la UI. ¿Te olvidaste de ponerla en el grupo?")
		
	elif is_eating:
		print("Shh... el cliente está comiendo.")
	else:
		print("Acción no válida en la mesa.")
		
func _on_timer_timeout() -> void:
	is_eating = false
	has_dirty_dish = true
	print("El cliente terminó de comer. Dejó un plato sucio y se va.")
	
	if current_customer != null:
		current_customer.leave_restaurant()
		current_customer = null 
	
func seat_customer(customer_node: CharacterBody2D) -> void:
	is_occupied = true
	has_customer_waiting = true
	current_customer = customer_node # Guardamos la referencia
	print("Un cliente se ha sentado. Esperando al mesero para pedir.")
