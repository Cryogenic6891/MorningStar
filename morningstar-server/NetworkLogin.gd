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
	refresh_data()

func refresh_data():
	client_dictionary = client_data.data
	character_dictionary = character_data.data

func update_data_files():
	var char_write = JSON.stringify(character_dictionary)
	FileAccess.open("res://characters.json",FileAccess.WRITE).store_string(char_write)
	var client_write = JSON.stringify(client_dictionary)
	FileAccess.open("res://clientprofiles.json",FileAccess.WRITE).store_string(client_write)

# Client RPCs (these are only called on the client)
@rpc
func message_to_client(_message):
	pass #not called here

@rpc
func character_select(_char1,_char2,_char3,_char4):
	pass #not called here

# Server RPCs
@rpc("any_peer")
func authorize_char_creation(id,slot,char_class,char_aspect,char_name, username):
	refresh_data()
	var new_character = {
	"name": char_name,
	"class": char_class,
	"aspect": char_aspect,
	"level": 1,
	"scene": null,
	"position": null,
	"status": null,
	"inventory": null
	}
	client_dictionary[username][slot] = new_character
	character_dictionary[char_name] = {
	"class": char_class,
	"aspect": char_aspect,
	"level": 1,
	"scene": null,
	"position": null,
	"status": null,
	"inventory": null
	}
	update_data_files()

@rpc ("any_peer")
func authorize_client(id,username,password):
	refresh_data()
	if client_dictionary.has(username):
		if client_dictionary[username]["password"] == password:
			rpc_id(id, "character_select", client_dictionary[username]["character1"], client_dictionary[username]["character2"], client_dictionary[username]["character3"], client_dictionary[username]["character4"])
	else:
		rpc_id(id,"message_to_client","Username Not Found")
		await get_tree().create_timer(1).timeout
		multiplayer.multiplayer_peer.disconnect_peer(id)

@rpc ("any_peer")
func request_delete_character(character,username,slot):
	refresh_data()
	character_dictionary.erase(str(character))
	client_dictionary[str(username)][slot] = null
	update_data_files()
