extends CharacterBody3D

#Movement Variables
var speed = 5.0
var rotation_speed = 5.0

#Animation State
var is_moving = false

#References
@onready var camera: Camera3D = $Camera3D
@onready var navagent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer

func _ready():
	velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if navagent.is_target_reachable():
		move_toward_target(delta)

#send scene, position, rotation

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
		is_moving = true

func move_toward_target(_delta):
	var target_position = navagent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	direction.y = 0
	
	if global_position.distance_to(target_position) > 0.1:
		look_at(global_position + direction, Vector3.UP)
	
	velocity = direction * speed
	move_and_slide()
	
	if is_moving and global_position.distance_to(target_position) > 0.1:
		anim_player.play("running")
	else:
		anim_player.play("idle")
	
	if global_position.distance_to(navagent.target_position) < 0.1:
		velocity = Vector3.ZERO
		is_moving = false
		anim_player.play("idle")
