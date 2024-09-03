extends Node

var client_data = preload("res://clientprofiles.json")
var character_data = preload("res://characters.json")
var character_dictionary : Dictionary
var client_dictionary :  Dictionary

# Schema: client profile
	#"cryogenic": {
		#"username": "cryogenic",
		#"password": "Bio!1619",
		#"email": "cboyda@runic.ca",
		#"status": "Admin",
		#"character1": null,
		#"character2": null,
		#"character3": null,
		#"character4": null
	#}

# Schema: character profile
	#"Bormot": {
	#"class": "King",
	#"aspect": "Diamonds",
	#"level": 1,
	#"scene": null,
	#"position": null,
	#"status": null,
	#"inventory": null
	#}

func _ready() -> void:
	client_dictionary = client_data.data
	character_dictionary = character_data.data

# validate_username

# validate_password

# validate_character_name

# Client RPCs
@rpc
func message_to_client(_message):
	pass

@rpc
func character_select(_char1,_char2,_char3,_char4):
	pass

# Server RPCs
@rpc("any_peer")
func authorize_char_creation(id,slot : int,character : Dictionary):
	character_dictionary = character_data.data

@rpc ("any_peer")
func authorize_client(id,username,password):
	client_dictionary = client_data.data
	if client_dictionary.has(username):
		if client_dictionary[username]["password"] == password:
			rpc_id(id, "character_select", client_dictionary[username]["character1"], client_dictionary[username]["character2"], client_dictionary[username]["character3"], client_dictionary[username]["character4"])
	else:
		rpc_id(id,"message_to_client","Username Not Found")
		await get_tree().create_timer(1).timeout
		multiplayer.multiplayer_peer.disconnect_peer(id)

@rpc ("any_peer")
func request_delete_character(character,username,slot):
	character_dictionary = character_data.data
	client_dictionary = client_data.data
	character_dictionary.erase(str(character))
	client_dictionary[str(username)][slot] = null
	var char_write = JSON.stringify(character_dictionary)
	FileAccess.open("res://characters.json",FileAccess.READ_WRITE).store_string(char_write)
	var check = load("res://characters.json")
	print(check.data)
	var client_write = JSON.stringify(client_dictionary)
