extends Node

var client_data = preload("res://clientprofiles.json")
var client_dictionary

func _ready() -> void:
	client_dictionary = client_data.data

@rpc ("any_peer")
func authorize_client(id,username,password):
	if client_dictionary.has(username):
		print("found")
	else:
		print("username not found")
		rpc_id(id,"message_to_client","Username Not Found")
		await get_tree().create_timer(1).timeout
		multiplayer.multiplayer_peer.disconnect_peer(id)

@rpc
func message_to_client(_message):
	pass
