extends Camera3D



func _ready():
	#set isometric angle
	transform.origin = Vector3(10,10,10)
	look_at(Vector3(0,0,0), Vector3(0,1,0))
