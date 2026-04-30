extends Area2D

var has_customer_waiting: bool = true
var is_waiting_for_food: bool = false
var is_eating: bool = false
var has_dirty_dish: bool = false

@onready var eat_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var waiters = get_tree().get_first_node_in_group("Waiters")
		
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# CASO 1: El cliente pide la comida
	if waiter.actual_state == waiter.HandState.EMPTY and has_customer_waiting:
		waiter.actual_state = waiter.HandState.ORDER
		has_customer_waiting = false
		is_waiting_for_food = true
		print("El mesero tomó la orden. La mesa ahora espera la comida.")
		
	# CASO 2: El mesero entrega el plato listo
	elif waiter.actual_state == waiter.HandState.DISH_READY and is_waiting_for_food:
		print("Plato entregado, el cliente empieza a comer.")
		
		# Vaciamos las manos del mesero para que pueda atender otras mesas
		waiter.actual_state = waiter.HandState.EMPTY
		
		# Cambiamos los estados de la mesa y arrancamos el timer de consumo
		is_waiting_for_food = false
		is_eating = true
		eat_timer.start()
	# CASO 3: Recoger el plato sucio
	elif waiter.actual_state == waiter.HandState.EMPTY and has_dirty_dish:
		print("Mesero recogió el plato sucio. La mesa está limpia.")
		var ui = get_tree().get_first_node_in_group("UI_GROUP")
		if ui:
			ui.Add_Money(100)
			print("Plata entregada con éxito")
		else:
			print("Error: No encontré la UI. ¿Te olvidaste de ponerla en el grupo?")
		
		# El mesero ahora carga el plato sucio
		waiter.actual_state = waiter.HandState.DIRTY_DISH
		
		# Reseteamos la mesa para que pueda venir un nuevo cliente
		has_dirty_dish = false
		has_customer_waiting = true # Esto permite que el ciclo empiece de nuevo	
	# CASOS EXTRA (Feedback en consola)
	elif is_eating:
		print("Shh... el cliente está comiendo.")
	else:
		print("Acción no válida en la mesa.")

# Se ejecuta cuando pasan los 4 segundos del Timer
func _on_timer_timeout() -> void:
	is_eating = false
	has_dirty_dish = true
	print("El cliente terminó de comer. Dejó un plato sucio y se fue.")
