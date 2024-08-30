extends Node

var ip : String = "192.168.1.64"
var port = 6660
var connection_id

func _ready():
	create_client()

func create_client():
	print("Creating connection")
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(disconnected_from_server)
	var client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client
	connection_id = client.get_unique_id()

func connected_to_server():
	print("Connected to main server at: " + str(connection_id))

func disconnected_from_server():
	print("Disconnected from server")

@rpc("any_peer")
func message_to_client():
	print("message to client")
