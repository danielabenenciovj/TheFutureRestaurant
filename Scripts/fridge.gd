extends Area2D

@export var tex_gaseosa: Texture2D
@export var tex_cerveza: Texture2D

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	if waiter.actual_state == waiter.HandState.DRINK_ORDER:
		var drink_name = waiter.current_drink_order
		var has_stock = false
		
		# 1. Revisamos si hay stock y lo descontamos
		if drink_name == "gaseosa" and Global.stock_gaseosa > 0:
			Global.stock_gaseosa -= 1
			has_stock = true
		elif drink_name == "cerveza" and Global.stock_cerveza > 0:
			Global.stock_cerveza -= 1
			has_stock = true
			
		# 2. Si hay stock, le damos la bebida al mozo
		if has_stock:
			print("Heladera entrega: ", drink_name)
			waiter.actual_state = waiter.HandState.DRINK
			waiter.current_item_texture = get_texture_for_drink(drink_name)
			
		# 3. Si NO hay stock, el mozo se rinde
		else:
			print("¡No hay stock de ", drink_name, "! El mozo cancela la acción.")
			# Vaciamos las manos del mozo y lo liberamos
			waiter.actual_state = waiter.HandState.EMPTY
			waiter.active_table = null
			waiter.current_drink_order = ""
			
			# Como el mozo canceló la acción, la mesa se queda esperando la bebida.
			# El timer de paciencia del cliente seguirá corriendo hasta que se enoje y se vaya.

func get_texture_for_drink(drink_name: String) -> Texture2D:
	match drink_name:
		"gaseosa": return tex_gaseosa
		"cerveza": return tex_cerveza
	return null
