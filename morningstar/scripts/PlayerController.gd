extends CharacterBody3D

#Movement Variables
var speed = 5.0
var target_position: Vector3 = Vector3()

#References
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var camera: Camera3D = $Camera3D
@onready var navagent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if target_position != Vector3():
		move_toward_target(delta)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		update_target_position(event)

func update_target_position(event: InputEventMouseButton):
	var ray_origin: Vector3 = camera.project_ray_origin(event.position)
	var ray_direction: Vector3 = camera.project_ray_normal(event.position)
	
	raycast.transform.origin = ray_origin
	raycast.target_position = ray_direction * 1000
	raycast.force_raycast_update()
	
	print("Ray origin: ", ray_origin)
	print("Ray direction: ", ray_direction)
	
	if raycast.is_colliding():
		target_position = raycast.get_collision_point()
		print("Target position set to: ", target_position)
	else:
		print("Raycast did not collide with any surface.")

func move_toward_target(_delta):
	var direction = (target_position - global_transform.origin).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	
	if global_transform.origin.distance_to(target_position) < 0.1:
		velocity = Vector3.ZERO
		target_position = Vector3()
