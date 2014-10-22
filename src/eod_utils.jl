#=
EodData internal module functions
=#

# ==================
# Internal variables
const WS = "http://ws.eoddata.com/data.asmx"
const HOST_ADDRESS = "ws.eoddata.com"
const CONTENT_TYPE = "application/x-www-form-urlencoded"
const REQUEST_TIMEOUT = 60.0

# =========
# Functions

# get_response
# ------------
# Returns an xml tree.
# INPUT: Web Service Call, Web Service Call Parameters
# OUTPUT: Xml tree of the type ::ETree
# http://ws.eoddata.com/data.asmx?op=CountryList
function get_response(call::String, params::Dict{ASCIIString, ASCIIString})
	# Get response
	resp = HTTPC.post("$WS$call", params, RequestOptions(headers=[("Host",HOST_ADDRESS)], content_type=CONTENT_TYPE, request_timeout=REQUEST_TIMEOUT))

	# An http code other than 200 indicates an http response has NOT been successfully received from the server
	if resp.http_code != 200
		error("get_response() failed with the following information: $resp")
	end

	# A valid response may be received from the server (above), but the web service call may still not be successful
	parsed_xml = xp_parse(bytestring(resp.body))
	xml_parent_path = call == "/Login" ? "/LOGINRESPONSE" : "/RESPONSE"
	message = lowercase(strip(find(parsed_xml, "$xml_parent_path[1]{Message}")))
	if message != "success" && message != "login successful"
		error("get_response() failed with message returned of: $message")
	end

	return parsed_xml
end
