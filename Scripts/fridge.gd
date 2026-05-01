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
	# Si el mozo viene con un pedido de bebida, la heladera se la da al instante
	if waiter.actual_state == waiter.HandState.DRINK_ORDER:
		print("Heladera entrega: ", waiter.current_drink_order)
		
		# Cambiamos lo que tiene en las manos
		waiter.actual_state = waiter.HandState.DRINK
		waiter.current_item_texture = get_texture_for_drink(waiter.current_drink_order)
		waiter.current_drink_order = ""
	else:
		print("Acción no válida en la heladera.")
func get_texture_for_drink(drink_name: String) -> Texture2D:
	match drink_name:
		"gaseosa": return tex_gaseosa
		"cerveza": return tex_cerveza
	return null
