extends Node

var gateway_ip : String = "192.168.1.72"
var gateway_port = 6066 #6066, 6067, 6068
var sever_port = 6068
var connection_id

func connect_to_gateway():
	print("Connecting to Gateway")
	var client = ENetMultiplayerPeer.new()
	client.create_client(gateway_ip, gateway_port)
	multiplayer.multiplayer_peer = client
	connection_id = client.get_unique_id()
