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
		#"status": "Admin" admin, active, inactive
		#"character1": null, character dictionary
		#"character2": null,
		#"character3": null,
		#"character4": null
	#}

# Schema: character profile
	#"Bormot": {
	#"class": "King",
	#"aspect": "Diamonds",
	#"level": 1,
	#"scene": null, name
	#"position": null, [Vector3,Rotation]
	#"status": null, online, offline
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

func authorize_char_name(char_name):
	if char_name.length() < 10 and char_name.length() > 2:
		var name_regex = RegEx.new()
		var pattern = r"^[a-zA-Z\s-]+$"
		var error = name_regex.compile(pattern)
		if error != OK:
			return false
		var match = name_regex.search(char_name)
		return match != null
	return false

func is_valid_email(email : String):
	var email_regex = RegEx.new()
	var pattern = r"^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$"
	var error = email_regex.compile(pattern)
	if error != OK:
		return false
	var match = email_regex.search(email)
	return match != null

func is_valid_username(username):
	refresh_data()
	if client_dictionary.has(username):
		return false
	else:
		return true

func is_valid_password(password):
	var password_regex = RegEx.new()
	var pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()]).{8,16}$"
	var error = password_regex.compile(pattern)
	if error != OK:
		return false
	var match = password_regex.search(password)
	return match != null

# Client RPCs (these are only called on the client)
@rpc
func message_to_client(_message):
	pass #not called here

@rpc
func character_select(_char1,_char2,_char3,_char4):
	pass #not called here

@rpc
func alert_to_client(_message):
	pass

@rpc
func confirmed_char_creation(_char_name,_char_class,_char_aspect):
	pass

@rpc
func confirmed_client_creation():
	pass

# Server RPCs
@rpc("any_peer")
func authorize_char_creation(id,slot,char_class,char_aspect,char_name_input, username):
	var char_name = char_name_input.to_lower()
	char_name = char_name.capitalize()
	refresh_data()
	if character_dictionary.has(char_name):
		rpc_id(id,"alert_to_client","Name Already Exists")
		return
	if authorize_char_name(char_name):
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
		rpc_id(id,"confirmed_char_creation",char_name,char_class,char_aspect)
	else:
		rpc_id(id,"alert_to_client","Invalid Character Name")

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
	if client_dictionary[str(username)][slot]["name"] == str(character):
		character_dictionary.erase(str(character))
		client_dictionary[str(username)][slot] = null
		update_data_files()

@rpc("any_peer")
func request_client_profile(id,username,password,email):
	refresh_data()
	var failed = true
	if is_valid_username(username):
		if is_valid_password(password):
			if is_valid_email(email):
				client_dictionary[username] = {
					"username": username,
					"password": password,
					"email": email,
					"status": "Active",
					"character1": null,
					"character2": null,
					"character3": null,
					"character4": null
				}
				failed = false
				rpc_id(id,"confirmed_client_creation")
				update_data_files()
	if failed:
		rpc_id(id,"alert_to_client","Invalid Registration")
