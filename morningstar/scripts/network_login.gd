extends Control

#Login Screen
@onready var login_panel = $BasePanel
@onready var username_input = $BasePanel/CenterContainer/UserContainer/UserInput
@onready var password_input = $BasePanel/CenterContainer/PasswordContainer/PasswordInput
@onready var login_button = $BasePanel/CenterContainer/LoginButton
@onready var register_button = $BasePanel/CenterContainer/RegisterButton
@onready var login_status = $BasePanel/CenterContainer/LoginStatus
@onready var text_animation = $AnimationPlayer

#Character Select Screen
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

func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server)
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

func connected_to_server():
	text_animation.stop()
	login_status.text = "Connection to Server Successful"
	await get_tree().create_timer(1).timeout
	rpc_id(1,"authorize_client",multiplayer.get_unique_id(),username_input.text,password_input.text)

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

func _on_char_1_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_char_2_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_char_3_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_char_4_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


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

#Server RPCs
@rpc
func authorize_client(_id,_username,_password):
	pass

@rpc
func authorize_char_creation(_id,_slot,_character):
	pass
