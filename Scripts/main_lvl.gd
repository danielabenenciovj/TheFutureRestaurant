extends Node2D

@export var customer_scene: PackedScene

# Ahora referenciamos directamente a la escena de la puerta
@onready var main_door: Node2D = $Door
@onready var spawn_timer: Timer = $CustomerSpawnTimer

var is_restaurant_open: bool = true

var current_spawn_time: float = 15.0

func _ready() -> void:
	print("El restaurante está abierto. Empezarán a llegar clientes.")
	
	main_door.customer_ready_to_spawn.connect(_on_door_ready_to_spawn)
	
	# --- 1. LÓGICA DE MESAS ---
	var all_tables = get_tree().get_nodes_in_group("Tables")
	
	# Definimos cuántas mesas usar. Ejemplo: Nivel 1 = 2 mesas, Nivel 2 = 3 mesas.
	var tables_to_unlock = Global.restaurant_level + 1 
	
	for i in range(all_tables.size()):
		if i < tables_to_unlock:
			# Mesa desbloqueada
			all_tables[i].show()
			all_tables[i].process_mode = Node.PROCESS_MODE_INHERIT
			all_tables[i].is_occupied = false
		else:
			# Mesa bloqueada (la ocultamos y la marcamos ocupada para que el cliente la ignore)
			all_tables[i].hide()
			all_tables[i].process_mode = Node.PROCESS_MODE_DISABLED
			all_tables[i].is_occupied = true 
			
	# --- 2. LÓGICA DE DIFICULTAD (TIEMPO DE SPAWN) ---
	# Arrancamos en 15 segs, y le restamos 2 segs por cada nivel extra.
	# max(5.0, ...) asegura que nunca spawneen más rápido que cada 5 segundos.
	current_spawn_time = max(5.0, 15.0 - ((Global.restaurant_level - 1) * 2.0))
	print("Tiempo entre clientes para este nivel: ", current_spawn_time, " segundos.")
	
	# El primer cliente del día siempre entra rápido (a los 3 segs)
	spawn_timer.wait_time = 3.0
	spawn_timer.start()

# Esta función sigue ejecutándose cada 15 segundos
func _on_customer_spawn_timer_timeout() -> void:
	# Si era el primer cliente (3 segs), cambiamos el tiempo a la velocidad del nivel actual
	if spawn_timer.wait_time == 3.0:
		spawn_timer.wait_time = current_spawn_time
		
	main_door.open_door()

# Esta función se activa únicamente cuando la puerta termina su animación de abrirse
func _on_door_ready_to_spawn(spawn_pos: Vector2) -> void:
	if customer_scene != null:
		var new_customer = customer_scene.instantiate()
		
		# Usamos la posición que nos mandó la puerta a través de la señal
		new_customer.global_position = spawn_pos
		add_child(new_customer)
	else:
		print("Error: No cargaste la escena del cliente en el Inspector.")
		
func stop_spawning_customers() -> void:
	print("¡El tiempo se acabó! Cerrando las puertas...")
	
	is_restaurant_open = false
	# Cambiá "$SpawnTimer" por el nombre exacto del Timer que usás para 
	# llamar a open_door() o instanciar a los clientes.
	if has_node("CustomerSpawnTimer"):
		$CustomerSpawnTimer.stop()
		
func check_end_of_day() -> void:
	# Si el timer todavía no llegó a cero, no hacemos nada
	if is_restaurant_open:
		return
		
	var customers_left = get_tree().get_nodes_in_group("Customers").size()
	
	if customers_left <= 1:
		print("¡Último cliente fuera! Pasando a la pantalla de resumen...")
		
		Global.current_day += 1
		
		get_tree().change_scene_to_file("res://Scenes/day_summary_ui.tscn")
