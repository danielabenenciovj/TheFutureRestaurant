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
@onready var food_dish_sprite = $FoodDishSprite
@onready var drink_sprite = $DrinkSprite #

@export var tex_dirty_generic: Texture2D
@export var tex_dirty_locro: Texture2D

var served_dish: String = ""

var consumed_food: String = ""
var consumed_drink: String = ""

var menu_prices = {
	"pizza": 50,      # Rápida, barata
	"empanadas": 80,  
	"choripan": 100,   
	"locro": 150,     # Lenta, cara
	"gaseosa": 15,    # (Te costó 5, ganás 10)
	"cerveza": 25     # (Te costó 10, ganás 15)
}

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
		waiter.current_item_texture = dirty_dish_sprite.texture
		
		dirty_dish_sprite.visible = false
		has_dirty_dish = false
		is_occupied = false
		has_customer_waiting = false
		is_waiting_for_food = false
		current_customer = null 
	
# --- NUEVO: CALCULAMOS EL PAGO ---
		var total_payment = 0
		
		if menu_prices.has(consumed_food):
			total_payment += menu_prices[consumed_food]
			
		# Chequeamos la bebida (porque podría no haberla recibido si se enojó, o haber tomado cerveza)
		if menu_prices.has(consumed_drink):
			total_payment += menu_prices[consumed_drink]
			
		print("El cliente pagó: $", total_payment)
		
		Global.money += total_payment
		Global.daily_profit += total_payment
		Global.total_orders_today += 1
	
		consumed_food = ""
		consumed_drink = ""
		
		var ui = get_tree().get_first_node_in_group("UI_GROUP")
		if ui: ui.Update_Money()
		
		return

	# 2. Tomar orden de BEBIDA
	if has_customer_waiting and not is_waiting_for_drink and waiter.actual_state == waiter.HandState.EMPTY:
		waiter.actual_state = waiter.HandState.DRINK_ORDER
		waiter.active_table = self
		
		if current_customer != null:
			waiter.current_drink_order = current_customer.desired_drink
			
		has_customer_waiting = false
		is_waiting_for_drink = true
		print("Orden de bebida tomada: ", waiter.current_drink_order)
		return

	# 3. Entregar BEBIDA
	if is_waiting_for_drink and waiter.actual_state == waiter.HandState.DRINK and waiter.active_table == self:
		print("¡Bebida entregada!")
		
		drink_sprite.texture = waiter.current_item_texture
		drink_sprite.visible = true
		
		if current_customer != null:
			consumed_drink = current_customer.desired_drink
		
		
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null
		waiter.current_item_texture = null
		
		is_waiting_for_drink = false
		needs_food_order = true
		
		return

	# 4. Tomar orden de COMIDA
	if needs_food_order and waiter.actual_state == waiter.HandState.EMPTY:
		if current_customer != null:
			current_customer.take_order() 
			# Le pasamos el nombre del plato al mozo
			waiter.current_order_name = current_customer.desired_dish 
		
		waiter.actual_state = waiter.HandState.FOOD_ORDER
		waiter.active_table = self
		needs_food_order = false
		is_waiting_for_food = true
		print("Orden tomada: ", waiter.current_order_name)
		return

	# 5. Entregar COMIDA
	if is_waiting_for_food and waiter.actual_state == waiter.HandState.DISH_READY and waiter.active_table == self:
		print("¡Plato entregado!")
		
		served_dish = waiter.current_order_name
		
		food_dish_sprite.texture = waiter.current_item_texture
		food_dish_sprite.visible = true
		
		consumed_food = served_dish
		
		waiter.actual_state = waiter.HandState.EMPTY
		waiter.active_table = null 
		waiter.current_item_texture = null
		waiter.current_order_name = ""
		
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
	
	if served_dish == "locro":
		dirty_dish_sprite.texture = tex_dirty_locro
	else:
		dirty_dish_sprite.texture = tex_dirty_generic
		
	food_dish_sprite.visible = false
	dirty_dish_sprite.visible = true
	drink_sprite.visible = false
	
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
	
func abandon_table() -> void:
	is_occupied = false
	has_customer_waiting = false
	is_waiting_for_drink = false
	needs_food_order = false
	is_waiting_for_food = false
	has_dirty_dish = false
	current_customer = null
	
	# Si tenías el sprite del plato sucio, nos aseguramos de apagarlo por si acaso
	if has_node("DirtyDishSprite"):
		$DirtyDishSprite.visible = false
		
	if has_node("FoodDishSprite"):
		$FoodDishSprite.visible = false
		
	if has_node("DrinkSprite"):
		$DrinkSprite.visible = false	
	print("El cliente se hartó y se fue. La mesa vuelve a estar 100% libre.")
