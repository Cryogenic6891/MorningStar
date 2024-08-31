extends Control

@onready var username_input = $BasePanel/CenterContainer/UserContainer/UserInput
@onready var password_input = $BasePanel/CenterContainer/PasswordContainer/PasswordInput

@onready var login_button = $BasePanel/CenterContainer/LoginButton
@onready var register_button = $BasePanel/CenterContainer/RegisterButton

@onready var login_status = $BasePanel/CenterContainer/LoginStatus
@onready var text_animation = $AnimationPlayer

func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_gateway)
	multiplayer.connection_failed.connect(failed_connection_to_gateway)

func _on_login_button_pressed() -> void:
	stop_actions(true)
	login_status.text = "Connecting to Gateway..."
	text_animation.play("text_wait")
	NetworkManager.connect_to_gateway()

func connected_to_gateway():
	text_animation.stop()
	login_status.text = "Connection to Gateway Successful"
	await get_tree().create_timer(1).timeout
	rpc_id(1,"check_data_files",multiplayer.get_unique_id(),username_input.text,password_input.text)

func failed_connection_to_gateway():
	stop_actions(false)
	text_animation.stop()
	login_status.text = "Connection to Gateway Failed"

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
func check_data_files(_id,_username,_password):
	pass
