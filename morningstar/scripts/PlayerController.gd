extends CharacterBody3D

#Movement Variables
var speed = 5.0

#References
@onready var camera: Camera3D = $Camera3D
@onready var navagent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(_delta):
	if navagent.is_target_reachable():
		move_toward_target()

func _input(event):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		update_target_position()

func update_target_position():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_length = 100
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = ray_origin + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = ray_origin
	ray_query.to = ray_direction

	var result = space.intersect_ray(ray_query)
	if result:
		navagent.target_position = result.position

func move_toward_target():
	var target_position = navagent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	move_and_slide()
