# =================================
# EodData internal module functions

# =========
# Functions

# get_response
# ------------
# Returns an xml tree.
# INPUT: Web Service Call, Web Service Call Parameters
# OUTPUT: Xml tree of the type ::ETree
# http://ws.eoddata.com/data.asmx?op=CountryList
function get_response(call::String, params::Dict{ASCIIString,ASCIIString})
	const WS = "http://ws.eoddata.com/data.asmx"
	const HOST_ADDRESS = "ws.eoddata.com"
	const CONTENT_TYPE = "application/x-www-form-urlencoded"
	const REQUEST_TIMEOUT = 60.0

	resp = HTTPC.post("$WS$call", params, RequestOptions(headers=[("Host",HOST_ADDRESS)], content_type=CONTENT_TYPE, request_timeout=REQUEST_TIMEOUT))

	if resp.http_code != 200
		error("get_response() failed with message returned of: $resp")
	end

	return parsed_xml = xp_parse(bytestring(resp.body))
end
