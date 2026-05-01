extends CharacterBody2D

@export var speed: float = 150.0
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
	if current_state == CustomerState.AT_TABLE:
		return
		
	if current_state == CustomerState.LEAVING and global_position.distance_to(spawn_position) < 60.0:
		queue_free()
		return
		
	# NUEVO: Lógica de escaneo constante en la puerta
	if current_state == CustomerState.LOOKING_FOR_TABLE and target_table == null:
		search_timer += delta
		if search_timer >= 1.0: # Cada 1 segundo exacto escanea el salón
			search_timer = 0.0
			find_empty_table()
		return # Cortamos la función acá para que el cliente no intente caminar a ningún lado
		
	if nav_agent.is_navigation_finished():
		return
		
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	
	var intended_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	
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
				target_table.seat_customer(self) 
		
				$CollisionShape2D.set_deferred("disabled", true)
		
				nav_agent.avoidance_enabled = false
		
		# Le avisa a la mesa que llegó y le pasa su propia referencia (self)
				target_table.seat_customer(self) 
		
		elif current_state == CustomerState.LEAVING:
			queue_free()

# Esta función la va a llamar la mesa cuando termine de comer
func leave_restaurant() -> void:
	current_state = CustomerState.LEAVING
	
	# Aseguramos que su cuerpo físico siga desactivado
	$CollisionShape2D.set_deferred("disabled", true)
	
	# NUEVO: Apagamos su "campo de fuerza" para que no empuje a los que hacen fila
	nav_agent.avoidance_enabled = false
	
	nav_agent.target_position = spawn_position
