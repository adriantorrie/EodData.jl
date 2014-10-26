#=
	EodData internal module functions
=#

# ==================
# Internal constants
const WS = "http://ws.eoddata.com/data.asmx"
const HOST_ADDRESS = "ws.eoddata.com"
const CONTENT_TYPE = "application/x-www-form-urlencoded"
const REQUEST_TIMEOUT = 60.0

# =========
# Functions

# get_response()
# --------------
# Returns an xml tree.
# INPUT: Web Service Call, Web Service Call Parameters
# OUTPUT: Xml tree of the type ::ETree
# http://ws.eoddata.com/data.asmx?op=CountryList
function get_response(call::String, params::Dict{ASCIIString, ASCIIString})
	# Get response
	resp = HTTPC.post("$WS$call", params, RequestOptions(headers=[("Host",HOST_ADDRESS)],
														 content_type=CONTENT_TYPE,
														 request_timeout=REQUEST_TIMEOUT))
	validate_http_response(resp) && return xp_parse(bytestring(resp.body))
end

# set_quotes()
# --------------
# Returns a list of quotes
# INPUT: XML tress
# OUTPUT:  Dict() of quotes of type ::Dict{String, Quote}
function set_quotes(xml_tree::ETree)
	quotes = Dict{String, Quote}()
	for qt_xml in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
		quotes[qt.ticker_code * "_" * string(qt.date_time)] = qt = Quote(qt_xml)
	end
	return quotes
end

# set_quotes_2()
# --------------
# Returns a list of quotes
# INPUT: XML tress
# OUTPUT:  Dict() of quotes of type ::Dict{String, Quote_2}
function set_quotes_2(xml_tree::ETree)
	quotes = Dict{String, Quote_2}()
	for qt_xml in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
		quotes[qt.ticker_code * "_" * string(qt.date_time)] = qt = Quote_2(qt_xml)
	end
	return quotes
end

# set_tickers()
# --------------
# Returns a list of tickers
# INPUT: XML tree
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker}
function set_tickers(xml_tree::ETree)
	tickers = Dict{String, Ticker}()
	for tk_xml in find(xml_tree, "/RESPONSE/SYMBOLS/SYMBOL")
		tickers[tk.code] = tk = Ticker(tk_xml)
	end
	return tickers
end

# set_tickers_2()
# --------------
# Returns a list of tickers
# INPUT: XML tree
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker_2}
function set_tickers_2(xml_tree::ETree)
	tickers = Dict{String, Ticker_2}()
	for tk_xml in find(xml_tree, "/RESPONSE/SYMBOLS2/SYMBOL2")
		tickers[tk.code] = tk = Ticker_2(tk_xml)
	end
	return tickers
end

# set_technicals()
# --------------
# Returns a list of technicals
# INPUT: XML tree
# OUTPUT: Dict() of technicals of type ::Dict{String, Technical}
function set_technicals(xml_tree::ETree)
	# Shred xml_tree into a Dict{String, Technical}
	technicals = Dict{String, Technical}()
	for tc_xml in find(xml_tree, "/RESPONSE/TECHNICALS/TECHNICAL")
		technicals[tc.ticker_code] = tc = Technical(tc_xml)
	end
	return  technicals
end

# validate_http_response()
# --------------
# Returns true if an http code = 200 is received, error otherwise
# INPUT: Http response
# OUTPUT: Bool, or error
function validate_http_response(resp::Response)
	if resp.http_code != 200
		error("validate_http_response() failed with the following information: $(resp.headers)")
	else
		return true
	end
end

# validate_xml_login()
# --------------
# Returns true if the web service call to login returned a message of success, error otherwise
# INPUT: XML tree
# OUTPUT: Bool, or error
function validate_xml_login(xml_tree::ETree)
	message = lowercase(strip(find(xml_tree, "/LOGINRESPONSE[1]{Message}")))
	if message != "login successful"
		error("validate_xml_login() failed with message returned of: $message")
	else
		return true
	end
end

# validate_xml()
# --------------
# Returns true if the web service call returned a message of success, error otherwise
# INPUT: XML tree
# OUTPUT: Bool, or error
function validate_xml(xml_tree::ETree)
	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("validate_xml() failed with message returned of: $message")
	else
		return true
	end
end
