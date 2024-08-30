extends Node
var port = 6660

var clients_connected = 0
var max_clients = 100
var clients = {}
var client_info = {}

signal signal_client_connected(peer_id, client_info)
signal signal_client_disconnected(peer_id)
signal signal_server_disconnected

func _ready():
	if OS.has_feature("dedicated_server"):
		initialize_server()
		create_server()

func initialize_server():
	print("Initializing Server")
	multiplayer.peer_connected.connect(client_connected)
	multiplayer.peer_disconnected.connect(client_disconnected)
	multiplayer.connected_to_server.connect(client_connected_ok)
	multiplayer.connection_failed.connect(client_failed_connection)
	multiplayer.server_disconnected.connect(server_disconnected)

func create_server():
	var server = ENetMultiplayerPeer.new()
	server.create_server(port,max_clients)
	multiplayer.multiplayer_peer = server
	
	clients[1] = client_info

func client_connected(client_id):
	print("connected: " + str(client_id))

func client_disconnected(client_id):
	print("disconnected: " + str(client_id))

func client_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	clients[peer_id] = client_info
	signal_client_connected.emit(peer_id, client_info)

func client_failed_connection():
	multiplayer.multiplayer_peer = null

func server_disconnected():
	multiplayer.multiplayer_peer = null
	clients.clear()
	signal_server_disconnected.emit()
