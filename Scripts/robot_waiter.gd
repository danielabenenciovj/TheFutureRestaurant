extends CharacterBody2D

var active_table: Area2D = null
@export var speed: float = 600.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite2D

@export var tex_walk_up: Texture2D
@export var tex_walk_down: Texture2D
@export var tex_walk_left: Texture2D
@export var tex_walk_right: Texture2D

@export var tex_dirty_dish: Texture2D
@export var tex_drink_generic: Texture2D
var current_item_texture: Texture2D = null
var current_order_name: String = ""
var current_drink_order: String = ""

enum HandState { EMPTY, DRINK_ORDER, FOOD_ORDER, DISH_READY, DIRTY_DISH, DRINK }

var actual_state: HandState = HandState.EMPTY

var safe_vel: Vector2 = Vector2.ZERO

var target_interactable: Node = null

func _ready() -> void:
	
	nav_agent.path_desired_distance = 25.0
	nav_agent.target_desired_distance = 25.0
	
func _process(_delta: float) -> void:
	
	# 1. Acomodamos el plato según hacia dónde mire el dibujo de Walter
	if sprite.texture == tex_walk_right:
		$HeldItem.position = Vector2(25, 5)
		$HeldItem.z_index = 1
		
	elif sprite.texture == tex_walk_left:
		$HeldItem.position = Vector2(-25, 5)
		$HeldItem.z_index = 1
		
	elif sprite.texture == tex_walk_down:
		$HeldItem.position = Vector2(0, 15)
		$HeldItem.z_index = 1
		
	elif sprite.texture == tex_walk_up:
		$HeldItem.position = Vector2(0, -10)
		$HeldItem.z_index = -1 
		
	# 2. Mostramos u ocultamos el objeto según lo que tenga en la mano
	match actual_state:
		HandState.DIRTY_DISH:
			$HeldItem.texture = current_item_texture 
			$HeldItem.visible = true
			
		HandState.DRINK:
			$HeldItem.texture = current_item_texture 
			$HeldItem.visible = true
			
		HandState.DISH_READY:
			$HeldItem.texture = current_item_texture
			$HeldItem.visible = true
			
		_: # El guion bajo significa "En cualquier otro caso" (Como el estado EMPTY)
			$HeldItem.visible = false
			$HeldItem.texture = null
	
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
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	var intended_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	
	nav_agent.set_velocity(intended_velocity)

	velocity = safe_vel
	move_and_slide()

	# --- LÓGICA DE ANIMACIÓN Y DIRECCIÓN ---
	
	# Si la velocidad es mayor a un número pequeño (para evitar tirones)
	if velocity.length() > 10.0:
		# Comparamos qué movimiento es más fuerte: el horizontal o el vertical
		if abs(velocity.x) > abs(velocity.y):
			# Movimiento predominantemente HORIZONTAL
			if velocity.x > 0:
				sprite.texture = tex_walk_right
				sprite.flip_h = false
			else:
				# Si no tenés un sprite dibujado mirando a la izquierda, 
				# podés usar el de la derecha y espejarlo poniendo flip_h = true
				sprite.texture = tex_walk_left 
				sprite.flip_h = false 
		else:
			# Movimiento predominantemente VERTICAL
			if velocity.y > 0:
				sprite.texture = tex_walk_down
			else:
				sprite.texture = tex_walk_up
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	safe_vel = safe_velocity

func _on_navigation_agent_2d_navigation_finished() -> void:
	if target_interactable != null:
		
		target_interactable.interact(self)
	
		target_interactable = null
