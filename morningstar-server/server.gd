extends Node
var port = 6068 #6066, 6067, 6068


var clients_connected = 0
var max_clients = 100
var clients = {}
var client_info = {}

signal signal_client_connected(peer_id, client_info)

func _ready():
	#if OS.has_feature("dedicated_server"):
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
	print("connected: " + str(client_id) + " at " + get_time())

func client_disconnected(client_id):
	print("disconnected: " + str(client_id) + " at " + get_time())

func get_time():
	var time = Time.get_datetime_dict_from_system()
	var hourminutesecond = str(time["hour"]) + ":" + str(time["minute"]) + ":" + str(time["second"])
	return hourminutesecond

func client_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	clients[peer_id] = client_info
	signal_client_connected.emit(peer_id, client_info)

func client_failed_connection():
	multiplayer.multiplayer_peer = null

func server_disconnected():
	multiplayer.multiplayer_peer = null
	clients.clear()
