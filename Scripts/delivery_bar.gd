extends Area2D

@export var tex_empanadas: Texture2D
@export var tex_locro: Texture2D
@export var tex_choripan: Texture2D
@export var tex_pizza: Texture2D

@onready var dishes_visuals = $DishesVisuals
var ready_orders: Array[Dictionary] = []

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("--- 1. CLIC EN LA BARRA DETECTADO ---")
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()
			print("Enviando al mozo a la barra...")

func add_dish(order: Dictionary) -> void:
	ready_orders.append(order)
	var dish_name = order["dish"]
	
	var new_icon = TextureRect.new()
	new_icon.texture = get_texture_for_dish(dish_name)
	new_icon.name = dish_name 
	new_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	new_icon.custom_minimum_size = Vector2(40, 40)
	new_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dishes_visuals.add_child(new_icon)

func interact(waiter: CharacterBody2D) -> void:
	print("--- 2. EL MOZO LLEGÓ A LA BARRA ---")
	print("Estado actual del mozo: ", waiter.actual_state)
	print("Cantidad de platos listos: ", ready_orders.size())
	
	if waiter.actual_state == waiter.HandState.EMPTY and ready_orders.size() > 0:
		var order_to_deliver = ready_orders.pop_front()
		var dish_name = order_to_deliver["dish"]
		
		waiter.actual_state = waiter.HandState.DISH_READY
		waiter.active_table = order_to_deliver["table"]
		waiter.current_item_texture = get_texture_for_dish(dish_name)
		waiter.current_order_name = dish_name
		
		for child in dishes_visuals.get_children():
			if child.name == dish_name:
				child.queue_free()
				break 
				
		print("--- 3. ÉXITO: El mozo recogió ", dish_name, " ---")
	else:
		print("ERROR LÓGICO: El mozo no pudo recogerlo. ¿Las manos están vacías? ", waiter.actual_state == waiter.HandState.EMPTY)

func get_texture_for_dish(dish_name: String) -> Texture2D:
	match dish_name:
		"empanadas": return tex_empanadas
		"locro": return tex_locro
		"choripan": return tex_choripan
		"pizza": return tex_pizza
	return null
