extends Resource
class_name Client_Profile

#Credentials
var username : String #unique identifier
var password : String
var email : String
var created : String
enum status {ADMIN,FREE,PREMIUM,VALIDATING,INACTIVE}

#Characters
var char1name = null
var char2name = null
var char3name = null
var char4name = null
