extends Camera3D

@onready var player = get_parent()
var camera_offset = Vector3(10, 10, 10)

func _ready():
	if global_transform.origin.distance_to(player.global_transform.origin) > 0.1:
		look_at(Vector3(0,1,0), Vector3(0,1,0))

func _process(_delta):
	global_transform.origin = player.global_transform.origin + camera_offset
	if global_transform.origin.distance_to(player.global_transform.origin) > 0.1:
		look_at(player.global_transform.origin, Vector3.UP)
