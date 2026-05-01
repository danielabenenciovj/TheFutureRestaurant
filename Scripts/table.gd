extends Area2D

var is_occupied: bool = false
var has_customer_waiting: bool = false
var is_waiting_for_drink: bool = false 
var needs_food_order: bool = false
var is_waiting_for_food: bool = false
var is_eating: bool = false
var has_dirty_dish: bool = false

var current_customer: CharacterBody2D = null

@onready var dirty_dish_sprite = $DirtyDishSprite
@onready var eat_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var waiters = get_tree().get_first_node_in_group("Waiters")
		
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# 1. PRIORIDAD: Limpiar plato sucio
	if has_dirty_dish and waiter.actual_state == waiter.HandState.EMPTY:
		print("Mesero recogió el plato sucio.")
		waiter.actual_state = waiter.HandState.DIRTY_DISH
		dirty_dish_sprite.visible = false
		has_dirty_dish = false
		is_occupied = false
		has_customer_waiting = false
		is_waiting_for_food = false
		current_customer = null 
		
		var ui = get_tree().get_first_node_in_group("UI_GROUP")
		if ui: ui.Add_Money(100)
		return

	# 2. Tomar orden de BEBIDA
	if has_customer_waiting and waiter.actual_state == waiter.HandState.EMPTY:
		if current_customer != null:
			current_customer.take_order() # Esto reinicia los relojes de paciencia
		
		waiter.actual_state = waiter.HandState.DRINK_ORDER
		waiter.active_table = self
		has_customer_waiting = false
		is_waiting_for_drink = true
		print("Orden de bebida tomada.")
		return

	# 3. Entregar BEBIDA
	if is_waiting_for_drink and waiter.actual_state == waiter.HandState.DRINK and waiter.active_table == self:
		print("¡Bebida entregada!")
		waiter.actual_state = waiter.HandState.EMPTY
		is_waiting_for_drink = false
		needs_food_order = true
		return

	# 4. Tomar orden de COMIDA
	if needs_food_order and waiter.actual_state == waiter.HandState.EMPTY:
		if current_customer != null:
			current_customer.take_order() # Volvemos a reiniciar los relojes
		
		waiter.actual_state = waiter.HandState.FOOD_ORDER
		waiter.active_table = self
		needs_food_order = false
		is_waiting_for_food = true
		print("Orden de comida tomada.")
		return

	# 5. Entregar COMIDA
	if is_waiting_for_food and waiter.actual_state == waiter.HandState.DISH_READY and waiter.active_table == self:
		print("¡Plato entregado!")
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null 
		is_waiting_for_food = false
		is_eating = true
		
		if current_customer != null:
			current_customer.receive_food() # Frena el contador para que no se vaya enojado
			
		eat_timer.start()
		return

	# Si no se cumple nada de lo anterior
	if is_eating:
		print("El cliente está comiendo...")
	else:
		print("No hay nada que hacer en esta mesa ahora mismo.")
		
func _on_timer_timeout() -> void:
	is_eating = false
	has_dirty_dish = true
	
	dirty_dish_sprite.visible = true
	
	
	if current_customer != null:
		current_customer.leave_restaurant()
		current_customer = null 
	print("El cliente se fue. Mesa sucia.") 
	
func seat_customer(customer_node: CharacterBody2D) -> void:
	# Reiniciamos solo los estados de pedidos, NO el plato sucio
	is_eating = false
	is_waiting_for_food = false
	is_waiting_for_drink = false
	needs_food_order = false
	
	# ASIGNACIÓN NUEVA
	is_occupied = true
	has_customer_waiting = true
	current_customer = customer_node 
	print("Mesa activada para nuevo cliente: ", customer_node.name)
