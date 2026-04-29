extends CharacterBody2D

@export var speed: float = 250.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

enum HandState { EMPTY, ORDER, DISH_READY, DIRTY_DISH, DRINK }


var actual_state: HandState = HandState.EMPTY

var target_interactable: Node = null
func _ready() -> void:
	
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		nav_agent.target_position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:

	if nav_agent.is_navigation_finished():
		return
		
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	velocity = new_velocity
	
	
	move_and_slide()


func _on_navigation_agent_2d_navigation_finished() -> void:
	if target_interactable != null:
		
		target_interactable.interact(self)
	
		target_interactable = null
