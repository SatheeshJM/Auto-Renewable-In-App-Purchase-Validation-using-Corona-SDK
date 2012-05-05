



local function listener(event)
	--Actual Response From iTunes
	print(event.response)
	
	--json-decoded itunes Response 
	print(event.iTunes_StatusCode)
	print(event.iTunes_StatusCodeDescription)
	print(event.iTunes_Response)

end 




local validate = require "validate"
validate.start
{
receipt = "Your Receipt Here",
password = "Your shared secret key here",
listener = listener,				
testing = false,			--Should be true if you use sandbox receipt, false if you use actual receipt



--The following lines must be uncommented if you want your receipt to be verified by your server.
--The php for receipt verification is also included within the project
--[[							
serverValidation = true,
serverLink = "Link of your php file"
--]]
}







