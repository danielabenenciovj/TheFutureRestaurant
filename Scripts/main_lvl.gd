extends Node2D

@export var customer_scene: PackedScene

# Ahora referenciamos directamente a la escena de la puerta
@onready var main_door: Node2D = $Door
@onready var spawn_timer: Timer = $CustomerSpawnTimer

func _ready() -> void:
	print("El restaurante está abierto. Empezarán a llegar clientes.")
	
	# Conectamos por código la señal que creamos en la puerta a una función de este script
	main_door.customer_ready_to_spawn.connect(_on_door_ready_to_spawn)
	spawn_timer.wait_time = 3.0
	spawn_timer.start()

# Esta función sigue ejecutándose cada 15 segundos
func _on_customer_spawn_timer_timeout() -> void:
	if spawn_timer.wait_time == 3.0:
		spawn_timer.wait_time = 15.0
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
