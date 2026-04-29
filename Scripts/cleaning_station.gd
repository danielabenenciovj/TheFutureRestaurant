extends Area2D

var is_washing: bool = false

@onready var wash_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var waiters = get_tree().get_first_node_in_group("Waiters")
		if waiters != null:
			waiters.nav_agent.target_position = global_position
			waiters.target_interactable = self
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:
	# El mesero trae un plato sucio y la bacha no está ocupada
	if waiter.actual_state == waiter.HandState.DIRTY_DISH and not is_washing:
		print("Lavando platos")
		
		# Liberamos las manos del mesero inmediatamente
		waiter.actual_state = waiter.HandState.EMPTY
		
		is_washing = true
		wash_timer.start()
	
	elif is_washing:
		print("La bacha está ocupada lavando.")
	else:
		print("No tenés nada sucio para lavar.")

func _on_timer_timeout() -> void:
	is_washing = false
	print("Platos limpios, listos para la siguiente tanda.")
