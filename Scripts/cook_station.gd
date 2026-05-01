extends Area2D

@export var tex_empanadas: Texture2D
@export var tex_locro: Texture2D
@export var tex_choripan: Texture2D
@export var tex_pizza: Texture2D

@onready var cook_timer: Timer = $Timer
@onready var ready_food_sprite: Sprite2D = $ReadyFoodSprite

var is_cooking: bool = false
var is_food_ready: bool = false

# Ahora la cola guarda Diccionarios con la mesa y el nombre del plato
var orders_queue: Array[Dictionary] = []

var table_waiting_for_this_dish: Area2D = null
var current_cooking_dish: String = ""

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
		
	# RETIRAR PLATO LISTO
	elif waiter.actual_state == waiter.HandState.EMPTY and is_food_ready:
		waiter.actual_state = waiter.HandState.DISH_READY
		waiter.active_table = table_waiting_for_this_dish
		waiter.current_item_texture = get_texture_for_dish(current_cooking_dish)
	
		waiter.current_order_name = current_cooking_dish 
		
		is_food_ready = false
		table_waiting_for_this_dish = null 
		current_cooking_dish = ""
		ready_food_sprite.visible = false
		check_and_cook()

func check_and_cook() -> void:
	if is_cooking or is_food_ready or orders_queue.size() == 0:
		return
		
	var next_order = orders_queue.pop_front()
	table_waiting_for_this_dish = next_order["table"]
	current_cooking_dish = next_order["dish"]
	
	is_cooking = true
	# Asignamos el tiempo específico para este plato
	cook_timer.wait_time = cook_times[current_cooking_dish]
	cook_timer.start()
	print("Cocinando ", current_cooking_dish, " por ", cook_timer.wait_time, " segs.")

func _on_timer_timeout() -> void:
	is_cooking = false
	is_food_ready = true
	
	# Mostramos el asset correspondiente sobre la barra
	ready_food_sprite.texture = get_texture_for_dish(current_cooking_dish)
	ready_food_sprite.visible = true
	
	print("¡", current_cooking_dish, " listo!")

# Función auxiliar para convertir el texto en la imagen correcta
func get_texture_for_dish(dish_name: String) -> Texture2D:
	match dish_name:
		"empanadas": return tex_empanadas
		"locro": return tex_locro
		"choripan": return tex_choripan
		"pizza": return tex_pizza
	return null
