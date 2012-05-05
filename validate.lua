
--====================================================================--
-- Module: Validation of Auto Renewable in-app Purchases 
-- Author : Satheesh
-- 
-- License:
--
--    Permission is hereby granted, free of charge, to any person obtaining a copy of 
--    this software and associated documentation files (the "Software"), to deal in the 
--    Software without restriction, including without limitation the rights to use, copy, 
--    modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
--    and to permit persons to whom the Software is furnished to do so, subject to the 
--    following conditions:
-- 
--    The above copyright notice and this permission notice shall be included in all copies 
--    or substantial portions of the Software.
-- 
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
--    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
--    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
--    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
--    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
--    DEALINGS IN THE SOFTWARE.
--
-- Overview: 
--
--    This module can be used to verify and validate auto-renewable in-app purchases using Corona
--
--
-- Version : 1.0 
--
--
-- Usage:
--
--
-- local validate = require "validate"
-- validate.start
-- {
-- receipt = "Your Receipt Here",
-- password = "Your shared secret key here",
-- listener = listener,				
-- testing = true,					--Should be true if you use sandbox receipt, false if you use actual receipt

--The following lines must be uncommented if you want your receipt to be verified by your server.
--The php for receipt verification is also included within the project
--[[							
serverValidation = true,
serverLink = "Link of your php file"
--]]

--
--====================================================================--
--




local json = require "json"
local base64 = require "base64"


local errorMap = 
{
["0"] = "No Error",
["21000"] = "The App Store could not read the JSON object you provided.",
["21002"] = "The data in the receipt-data property was malformed.",
["21003"] = "The receipt could not be authenticated.",
["21004"] = "The shared secret you provided does not match the shared secret on file for your account.",
["21005"] = "The receipt server is not currently available.",
["21006"] = "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.",
["21007"] = "This receipt is a sandbox receipt, but it was sent to the production service for verification.",
["21008"] = "This receipt is a production receipt, but it was sent to the sandbox service for verification.",
}

local function preparePostData(receipt,params)
	
	local password = params.password
	local serverValidation = params.serverValidation
	
	--remove unwanted characters
	receipt = receipt:sub(2,-2)
	receipt = receipt:gsub(" ","")
	
	--Convert to ascii
	local ascii = ""
	local l = receipt:len()
	for i=1,l,2 do 
		local hex = receipt:sub(i,i+1)
		local dec = tonumber(hex, 16)
		if dec then 
			local char = string.char(dec)
			ascii = ascii..char
		end
	end
	
	
	--Encode to base 64
	local b64encode = base64.encode(ascii)
	
	if serverValidation then  
		--dont send password in case of server validation
		return b64encode
	end 
	
	--Convert to json 
	local jsn = json.encode 
	{
	receipt_data = b64encode,
	password = password,
	}
	jsn = jsn:gsub("receipt_data","receipt-data")
	
	return jsn 
end




local function start(params)
	
	local listener = params.listener or function(event) end 
	local testing = params.testing
	local link = testing and "https://sandbox.itunes.apple.com/verifyReceipt" 
								or "https://buy.itunes.apple.com/verifyReceipt"

	
	local receipt = params.receipt or "<>"
	local password = params.password or nil
	local serverValidation = params.serverValidation
	local serverLink = params.serverLink
	
	local postData
	
	if serverValidation then 
		postData = preparePostData(receipt,{serverValidation = true})
		postData = "receipt="..postData.."&testing="..(testing and 1 or 0)
		link = serverLink
	else 
		postData = preparePostData(receipt,{password = password})
	end
	
	
	local function localListener(event)

		local response = event.response 
		local decoded = json.decode(response)
		
		if type(decoded) == "table" then 
			event.iTunes_StatusCode = decoded.status 
			event.iTunes_Response = decoded
			event.iTunes_StatusCodeDescription = errorMap[tostring(event.iTunes_StatusCode)]
		end 

		listener(event)
	end 

	network.request(link,"POST",localListener,{body=postData})

end 


return {start = start}

