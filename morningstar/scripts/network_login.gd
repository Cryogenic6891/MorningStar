extends Control

#Login Screen
@onready var login_panel = $BasePanel
@onready var username_input = $BasePanel/CenterContainer/UserContainer/UserInput
@onready var password_input = $BasePanel/CenterContainer/PasswordContainer/PasswordInput
@onready var login_button = $BasePanel/CenterContainer/LoginButton
@onready var register_button = $BasePanel/CenterContainer/RegisterPanelButton
@onready var login_status = $BasePanel/CenterContainer/LoginStatus
@onready var text_animation = $AnimationPlayer

#Character Select Screen
var current_username
@onready var character_panel = $CharacterPanel
@onready var character_select_1 = $CharacterPanel/HBoxContainer/VBoxContainer/char1
@onready var character_select_2 = $CharacterPanel/HBoxContainer/VBoxContainer/char2
@onready var character_select_3 = $CharacterPanel/HBoxContainer/VBoxContainer/char3
@onready var character_select_4 = $CharacterPanel/HBoxContainer/VBoxContainer/char4
@onready var class_dropdown = $CharacterPanel/HBoxContainer/CreateChar/Class
@onready var aspect_dropdown = $CharacterPanel/HBoxContainer/CreateChar/Aspect
@onready var name_edit = $CharacterPanel/HBoxContainer/CreateChar/NameEdit
@onready var create_button = $CharacterPanel/HBoxContainer/CreateChar/CreateButton
@onready var character_profile_1 = null
@onready var character_profile_2 = null
@onready var character_profile_3 = null
@onready var character_profile_4 = null
var profile_dictionary
var current_profile
####
@onready var create_char_subpanel = $CharacterPanel/HBoxContainer/CreateChar
@onready var create_char_class = $CharacterPanel/HBoxContainer/CreateChar/Class
@onready var create_char_aspect = $CharacterPanel/HBoxContainer/CreateChar/Aspect
@onready var create_char_name = $CharacterPanel/HBoxContainer/CreateChar/NameEdit
@onready var create_char_button = $CharacterPanel/HBoxContainer/CreateChar/CreateButton
####
@onready var char_profile_subpanel = $CharacterPanel/HBoxContainer/CharProfile
@onready var char_profile_class = $CharacterPanel/HBoxContainer/CharProfile/Class
@onready var char_profile_aspect = $CharacterPanel/HBoxContainer/CharProfile/Aspect
@onready var char_profile_name = $CharacterPanel/HBoxContainer/CharProfile/NameLabel
@onready var char_profile_level = $CharacterPanel/HBoxContainer/CharProfile/Level
@onready var char_profile_enter = $CharacterPanel/HBoxContainer/CharProfile/EnterWorld
@onready var char_profile_delete = $CharacterPanel/HBoxContainer/CharProfile/DeleteChar
@onready var delete_confirmation = $ConfirmationDialog
var selected_character
var selected_slot
####
@onready var register_subpanel = $RegisterPanel
@onready var register_username = $RegisterPanel/CenterContainer/UserContainer/UserInput
@onready var register_password = $RegisterPanel/CenterContainer/PasswordContainer/PasswordInput
@onready var register_email = $RegisterPanel/CenterContainer/EmailContainer/EmailInput
@onready var register_request_button = $RegisterPanel/CenterContainer/RegisterButton
@onready var register_status = $RegisterPanel/CenterContainer/RegisterStatus
####
@onready var alert_panel = $AcceptDialog


func _ready() -> void:
	multiplayer.connection_failed.connect(failed_connection_to_server)
	multiplayer.server_disconnected.connect(disconnected_from_server)
	add_character_creation_options()

func add_character_creation_options():
	class_dropdown.add_item("King")
	class_dropdown.add_item("Queen")
	class_dropdown.add_item("Jack")
	aspect_dropdown.add_item("Hearts")
	aspect_dropdown.add_item("Diamonds")
	aspect_dropdown.add_item("Spades")
	aspect_dropdown.add_item("Clubs")

func _on_login_button_pressed() -> void:
	stop_actions(true)
	login_status.text = "Connecting to Server..."
	text_animation.play("text_wait")
	NetworkManager.connect_to_gateway()
	await multiplayer.connected_to_server
	text_animation.stop()
	login_status.text = "Connection to Server Successful"
	rpc_id(1,"authorize_client",multiplayer.get_unique_id(),username_input.text,password_input.text)
	current_username = username_input.text

func failed_connection_to_server():
	stop_actions(false)
	text_animation.stop()
	login_status.text = "Connection to Server Failed"

func disconnected_from_server():
	stop_actions(false)
	text_animation.stop()

func stop_actions(stop : bool):
	if stop:
		login_button.disabled = true
		username_input.editable = false
		password_input.editable = false
		register_button.disabled = true
		
	elif stop == false:
		username_input.editable = true
		password_input.editable = true
		login_button.disabled = false
		register_button.disabled = false

func close_all_panels():
	login_panel.visible = false
	character_panel.visible = false
	register_subpanel.visible = false

func _on_char_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_profile = 0
		profile_dictionary = character_profile_1
		character_subpanel(current_profile)
		selected_slot = "character1"
		reset_fields()
func _on_char_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_profile = 1
		profile_dictionary = character_profile_2
		character_subpanel(current_profile)
		selected_slot = "character2"
		reset_fields()
func _on_char_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_profile = 2
		profile_dictionary = character_profile_3
		character_subpanel(current_profile)
		selected_slot = "character3"
		reset_fields()
func _on_char_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_profile = 3
		profile_dictionary = character_profile_4
		character_subpanel(current_profile)
		selected_slot = "character4"
		reset_fields()

func reset_fields():
	create_char_class.selected = 0
	create_char_aspect.selected = 0
	create_char_name.text = ""

func _on_delete_char_pressed() -> void:
	delete_confirmation.visible = true
	await delete_confirmation.confirmed
	rpc_id(1,"request_delete_character", selected_character,current_username,selected_slot)
	profile_dictionary = null
	set_profile(current_profile)
	character_subpanel(current_profile)

func _on_enter_world_pressed() -> void:
	pass # Replace with function body.

func character_subpanel(chars):
	var options = [character_profile_1,character_profile_2,character_profile_3,character_profile_4]
	var char_label = [character_select_1,character_select_2,character_select_3,character_select_4]
	if options[chars] == null:
		create_char_subpanel.visible = true
		char_profile_subpanel.visible = false
		char_label[chars].text = " Empty " 
	else:
		create_char_subpanel.visible = false
		char_profile_subpanel.visible = true
		char_profile_class.text = "Class: " + str(options[chars]["class"])
		char_profile_aspect.text = "Aspect: " + str(options[chars]["aspect"])
		char_profile_name.text = "Name: " + str(options[chars]["name"])
		char_profile_level.text = "Level: " + str(options[chars]["level"])
		selected_character = options[chars]["name"]

func _on_create_button_pressed() -> void:
	await get_tree().create_timer(1).timeout
	rpc_id(1, "authorize_char_creation", multiplayer.get_unique_id(),selected_slot, str(class_dropdown.get_item_text(class_dropdown.selected)), str(aspect_dropdown.get_item_text(aspect_dropdown.selected)), name_edit.text, current_username)

func _on_register_button_pressed() -> void:
	NetworkManager.connect_to_gateway()
	await multiplayer.connected_to_server
	rpc_id(1, "request_client_profile", multiplayer.get_unique_id(), register_username.text, register_password.text,register_email.text)

func _on_cancel_button_pressed() -> void:
	close_all_panels()
	login_panel.visible = true

func _on_register_panel_button_pressed() -> void:
	close_all_panels()
	register_subpanel.visible = true

func set_profile(current,char_name = null):
	match current:
		0:
			character_profile_1 = profile_dictionary
			if char_name:
				character_select_1.text = " " + char_name + " "
		1:
			character_profile_2 = profile_dictionary
			if char_name:
				character_select_2.text = " " + char_name + " "
		2:
			character_profile_3 = profile_dictionary
			if char_name:
				character_select_3.text = " " + char_name + " "
		3:
			character_profile_4 = profile_dictionary
			if char_name:
				character_select_4.text = " " + char_name + " "

#Client RPCs
@rpc
func message_to_client(message):
	login_status.text = message

@rpc
func character_select(char1,char2,char3,char4):
	close_all_panels()
	character_panel.visible = true
	character_profile_1 = char1
	character_profile_2 = char2
	character_profile_3 = char3
	character_profile_4 = char4
	var options = [character_profile_1,character_profile_2,character_profile_3,character_profile_4]
	var chars = [character_select_1,character_select_2,character_select_3,character_select_4]
	for option in options:
		if option != null:
			var index = options.find(option)
			chars[index].text = " " + str(option["name"]) + " "

@rpc
func alert_to_client(message):
	alert_panel.dialog_text = message
	alert_panel.visible = true

@rpc
func confirmed_char_creation(char_name,char_class,char_aspect):
	profile_dictionary = {
		"name": char_name,
		"class": char_class,
		"aspect": char_aspect,
		"level": 1,
		"scene": null,
		"position": null,
		"status": null,
		"inventory": null
	}
	set_profile(current_profile,char_name)
	character_subpanel(current_profile)

@rpc
func confirmed_client_creation():
	register_email.text = ""
	register_password.text = ""
	register_username.text = ""
	close_all_panels()
	login_panel.visible = true
	login_status.text = "Successful Registration"

#Server RPCs
@rpc
func authorize_client(_id,_username,_password):
	pass

@rpc
func authorize_char_creation(_id,_slot,_character):
	pass

@rpc
func request_delete_character(_id,_character,_username):
	pass

@rpc
func request_client_profile(_id,_username,_password,_email):
	pass
