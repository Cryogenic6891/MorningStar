extends Control

@onready var username_input = $BasePanel/CenterContainer/UserContainer/UserInput
@onready var password_input = $BasePanel/CenterContainer/PasswordContainer/PasswordInput

@onready var login_button = $BasePanel/CenterContainer/LoginButton
@onready var register_button = $BasePanel/CenterContainer/RegisterButton

@onready var login_status = $BasePanel/CenterContainer/LoginStatus
@onready var text_animation = $AnimationPlayer

func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(failed_connection_to_server)
	multiplayer.server_disconnected.connect(disconnected_from_server)

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

@rpc
func authorize_client(_id,_username,_password):
	pass

@rpc
func message_to_client(message):
	print("test")
	login_status.text = message
