extends Area2D

@onready var cook_timer: Timer = $Timer

# Ahora conectamos la barra desde el Inspector
@export var delivery_bar: Area2D

var is_cooking: bool = false

# La cola sigue usando tu sistema de Diccionarios
var orders_queue: Array[Dictionary] = []
var current_cooking_order: Dictionary = {}

# Configurador de tiempos (en segundos)
var cook_times = {
	"empanadas": 5.0,
	"locro": 12.0,
	"choripan": 6.0,
	"pizza": 8.0
}

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# DEJAR COMANDA
	if waiter.actual_state == waiter.HandState.FOOD_ORDER:
		print("Cocina recibe comanda de: ", waiter.current_order_name)
		
		# Guardamos la mesa y el plato específico
		orders_queue.append({
			"table": waiter.active_table,
			"dish": waiter.current_order_name
		})
		
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null
		waiter.current_order_name = "" # Borramos su anotador
		
		check_and_cook()
		
	# Eliminamos el bloque "RETIRAR PLATO LISTO" de acá, porque ahora se retira en la barra.

func check_and_cook() -> void:
	# Si ya está cocinando o no hay fila, no hacemos nada
	if is_cooking or orders_queue.size() == 0:
		return
		
	# Sacamos el primer pedido de la fila
	current_cooking_order = orders_queue.pop_front()
	var dish_name = current_cooking_order["dish"]
	
	is_cooking = true
	# Asignamos el tiempo específico para este plato
	cook_timer.wait_time = cook_times[dish_name]
	cook_timer.start()
	print("Cocinando ", dish_name, " por ", cook_timer.wait_time, " segs.")

func _on_timer_timeout() -> void:
	is_cooking = false
	var dish_name = current_cooking_order["dish"]
	print("¡", dish_name, " listo! Enviando a la barra...")
	
	# Le mandamos el diccionario entero a la barra
	if delivery_bar != null:
		delivery_bar.add_dish(current_cooking_order)
	else:
		print("ERROR: No asignaste la DeliveryBar en el Inspector de la Cocina.")
	
	# Automáticamente empezamos a cocinar el siguiente si hay fila
	check_and_cook()
