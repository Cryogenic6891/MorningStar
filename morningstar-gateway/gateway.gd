extends Node
var port = 6066

# Accepts incoming requests from client ; 1 per second

# Action 1 - Login
# Sends request with credential info to Authenticator
# Accepts Authenticator result, successful/failed token
# Sends result to client, successful/failed token
# Logs attempt

# Action 2 - Register
# Sends request with credentials info to Authenticator
# Accepts Authenticator result, successful/failed credential creation
# Sends result to client, successful/failed credential creation
# Logs attempt
