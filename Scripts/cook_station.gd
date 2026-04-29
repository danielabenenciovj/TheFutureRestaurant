extends Area2D

var is_cooking: bool = false
var is_food_ready: bool = false

@onready var cook_timer: Timer = $Timer

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var waiters = get_tree().get_first_node_in_group("Waiters")
		
		if waiters != null:
		
			waiters.nav_agent.target_position = global_position
			
		
			waiters.target_interactable = self
			
			get_viewport().set_input_as_handled()

func interact(waiter: CharacterBody2D) -> void:

	if waiter.actual_state == waiter.HandState.ORDER and not is_cooking and not is_food_ready:
		print("La cocina recibe la comanda. ¡Empezando a cocinar!")
		

		waiter.actual_state = waiter.HandState.EMPTY

		is_cooking = true
		cook_timer.start()

	elif waiter.actual_state == waiter.HandState.EMPTY and is_food_ready:
		print("El mesero recogió el plato listo.")
		
		waiter.actual_state = waiter.HandState.DISH_READY
	
		is_food_ready = false
		
	elif is_cooking:
		print("la comida todavía se está cocinando")
	else:
		print("Acción no válida en la cocina.")

func _on_timer_timeout() -> void:
	is_cooking = false
	is_food_ready = true
	print("La comida está lista para ser retirada.")
