extends CharacterBody2D

@export var speed: float = 150.0
@export var max_food_wait_time: float = 30.0 # Tiempo que espera la comida antes de irse
var food_wait_timer: float = 0.0
var waiting_for_food: bool = false # Nuevo interruptor
@export var max_wait_time: float = 20.0 # Tiempo máximo que espera antes de irse
var wait_timer: float = 0.0
var waiting_for_order: bool = false
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var search_timer: float = 0.0

enum CustomerState { LOOKING_FOR_TABLE, AT_TABLE, LEAVING }
var current_state: CustomerState = CustomerState.LOOKING_FOR_TABLE

var target_table: Area2D = null
var spawn_position: Vector2

var safe_vel: Vector2 = Vector2.ZERO


func _ready() -> void:

	nav_agent.path_desired_distance = 25.0
	nav_agent.target_desired_distance = 25.0
	
	spawn_position = global_position 
	
	call_deferred("find_empty_table")

func find_empty_table() -> void:
	var tables = get_tree().get_nodes_in_group("Tables")
	
	for table in tables:
		if not table.is_occupied:
			target_table = table
			table.is_occupied = true 
			nav_agent.target_position = table.get_node("ChairPosition").global_position
			return

func _physics_process(delta: float) -> void:
	# 1. TIMERS (Siempre corren mientras el cliente exista)
	if waiting_for_order:
		wait_timer += delta
		if wait_timer >= max_wait_time:
			leave_restaurant()
			return

	if waiting_for_food:
		food_wait_timer += delta
		if food_wait_timer >= max_food_wait_time:
			leave_restaurant()
			return

	# 2. LÓGICA DE SALIDA (Si ya llegó a la puerta, desaparece)
	if current_state == CustomerState.LEAVING:
		if global_position.distance_to(spawn_position) < 60.0:
			queue_free()
			return
	
	# 3. BLOQUEO DE ASIENTO 
	# Solo hacemos 'return' si está en la mesa y NO se está yendo
	if current_state == CustomerState.AT_TABLE:
		return
		
	# 4. MOVIMIENTO (Solo llega aquí si está caminando a la mesa o a la salida)
	if current_state == CustomerState.LOOKING_FOR_TABLE and target_table == null:
		search_timer += delta
		if search_timer >= 1.0:
			search_timer = 0.0
			find_empty_table()
		return 
		
	if nav_agent.is_navigation_finished():
		return
		
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var intended_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(intended_velocity)
		velocity = safe_vel
	else:
		velocity = intended_velocity
	
	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:

	safe_vel = safe_velocity

func _on_navigation_agent_2d_navigation_finished() -> void:
	# Si llegó a la mesa
		if current_state == CustomerState.LOOKING_FOR_TABLE and target_table != null:
				current_state = CustomerState.AT_TABLE
				waiting_for_order = true
				target_table.seat_customer(self) 
		
				$CollisionShape2D.set_deferred("disabled", true)
		
				nav_agent.avoidance_enabled = false
		
		# Le avisa a la mesa que llegó y le pasa su propia referencia (self)
				target_table.seat_customer(self) 
		
		elif current_state == CustomerState.LEAVING:
			queue_free()
			
func take_order() -> void:
	waiting_for_order = false
	wait_timer = 0.0
	
	# Esto es lo que activa el segundo reloj:
	food_wait_timer = 0.0 
	waiting_for_food = true

# Esta función la va a llamar la mesa cuando termine de comer
func leave_restaurant() -> void:
	# Desvinculamos al cliente, pero dejamos que el mozo libere la mesa al limpiar
	target_table = null 
	
	# Apagamos los relojes
	waiting_for_order = false
	waiting_for_food = false
	
	# Iniciamos la salida
	current_state = CustomerState.LEAVING
	nav_agent.target_position = spawn_position 
	
	# Lo volvemos fantasma para que no moleste
	$CollisionShape2D.set_deferred("disabled", true)
	nav_agent.avoidance_enabled = false
	
	print("El cliente está saliendo del restaurante...")
	
func receive_food() -> void:
	waiting_for_food = false
	food_wait_timer = 0.0
	print("¡Por fin la comida! A comer.")
