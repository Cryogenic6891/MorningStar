extends Node

var server_ip : String = "192.168.1.72"
var server_port = 6068
var connection_id

func _ready() -> void:
	multiplayer.server_disconnected.connect(disconnected)

func connect_to_gateway():
	print("Connecting to Server")
	var client = ENetMultiplayerPeer.new()
	client.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = client
	connection_id = client.get_unique_id()

func disconnected():
	print("disconnected from server")
