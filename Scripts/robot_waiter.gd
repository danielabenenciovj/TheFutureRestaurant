extends CharacterBody2D

var active_table: Area2D = null
@export var speed: float = 600.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

enum HandState { EMPTY, ORDER, DISH_READY, DIRTY_DISH, DRINK }

var actual_state: HandState = HandState.EMPTY

var safe_vel: Vector2 = Vector2.ZERO

var target_interactable: Node = null

func _ready() -> void:
	
	nav_agent.path_desired_distance = 25.0
	nav_agent.target_desired_distance = 25.0
	
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		nav_agent.target_position = get_global_mouse_position()
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_areas = true
		
		var result = space_state.intersect_point(query)
		
		if result.size() > 0:
			var hit_object = result[0].collider
			if hit_object.is_in_group("Tables"): # Asegúrate que tus mesas estén en el grupo "Tables"
				target_interactable = hit_object
		else:
			target_interactable = null

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
		
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	var intended_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	
	
	nav_agent.set_velocity(intended_velocity)

	velocity = safe_vel
	move_and_slide()
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	safe_vel = safe_velocity

func _on_navigation_agent_2d_navigation_finished() -> void:
	if target_interactable != null:
		
		target_interactable.interact(self)
	
		target_interactable = null
