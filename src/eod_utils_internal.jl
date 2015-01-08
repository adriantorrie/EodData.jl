#=
    EodData internal utility functions
=#

# ==================
# Internal constants
const WS = "http://ws.eoddata.com/data.asmx"
const HOST_ADDRESS = "ws.eoddata.com"
const CONTENT_TYPE = "application/x-www-form-urlencoded"
const REQUEST_TIMEOUT = 600.0

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
    resp = HTTPC.post("$WS$call",
                      params,
                      RequestOptions(headers=[("Host",HOST_ADDRESS)],
                                    content_type=CONTENT_TYPE,
                                    request_timeout=REQUEST_TIMEOUT))
    validate_http_response(resp) && return xp_parse(bytestring(resp.body))
end

# set_countries()
# --------------
# Returns a collection of countries
# INPUT: XML tree
# OUTPUT:  Dict() of countries of type ::Dict{String, Country}
function set_countries(xml_tree::ETree)
    countries = Dict{String, Country}()
    for c_xml in find(xml_tree, "/RESPONSE/COUNTRIES/CountryBase")
        countries[c.code] = c = Country(c_xml)
    end
    return countries
end

# set_data_formats()
# --------------
# Returns a collection of data formats
# INPUT: XML tree
# OUTPUT:  Dict() of data formats of type ::Dict{String, Exchange}
function set_data_formats(xml_tree::ETree)
    formats = Dict{String, DataFormat}()
    for df_xml in find(xml_tree, "/RESPONSE/DATAFORMATS/DATAFORMAT")
        formats[df.code] = df = DataFormat(df_xml)
    end
    return formats
end

# set_exchanges()
# --------------
# Returns a collection of exchanges
# INPUT: XML tree
# OUTPUT:  Dict() of exchanges of type ::Dict{String, Exchange}
function set_exchanges(xml_tree::ETree)
    exchanges = Dict{String, Exchange}()
    for ex_xml in find(xml_tree, "/RESPONSE/EXCHANGES/EXCHANGE")
        exchanges[ex.code] = ex = Exchange(ex_xml)
    end
    return exchanges
end

# set_fundamentals()
# --------------
# Returns a collection of fundamentals
# INPUT: XML tree
# OUTPUT:  Dict() of fundamentals of type ::Dict{String, Fundamental}
function set_fundamentals(xml_tree::ETree)
    fundamentals = Dict{String, Fundamental}()
    for fl_xml in find(xml_tree, "/RESPONSE/FUNDAMENTALS/FUNDAMENTAL")
        fundamentals[fl.ticker_code] = fl = Fundamental(fl_xml)
    end
    return fundamentals
end

# set_quotes()
# --------------
# Returns a collection of quotes
# INPUT: XML tree
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
# Returns a collection of quotes
# INPUT: XML tree
# OUTPUT:  Dict() of quotes of type ::Dict{String, Quote_2}
function set_quotes_2(xml_tree::ETree)
    quotes = Dict{String, Quote_2}()
    for qt_2_xml in find(xml_tree, "/RESPONSE/QUOTES2/QUOTE2")
        quotes[qt_2.ticker_code * "_" * string(qt_2.date_time)] = qt_2 = Quote_2(qt_2_xml)
    end
    return quotes
end

# set_splits()
# --------------
# Returns a collection of splits
# INPUT: XML tree
# OUTPUT:  Dict() of splits of type ::Dict{String, Split}
function set_splits(xml_tree::ETree)
    splits = Dict{String, Split}()
    for sp_xml in find(xml_tree, "/RESPONSE/SPLITS/SPLIT")
        splits[sp.ticker_code * "_" * string(sp.date_time)] = sp = Split(sp_xml)
    end
    return splits
end

# set_technicals()
# --------------
# Returns a collection of technicals
# INPUT: XML tree
# OUTPUT: Dict() of technicals of type ::Dict{String, Technical}
function set_technicals(xml_tree::ETree)
    # Shred xml_tree into a Dict{String, Technical}
    technicals = Dict{String, Technical}()
    for tl_xml in find(xml_tree, "/RESPONSE/TECHNICALS/TECHNICAL")
        technicals[tl.ticker_code] = tl = Technical(tl_xml)
    end
    return  technicals
end

# set_tickers()
# --------------
# Returns a collection of tickers
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
# Returns a collection of tickers
# INPUT: XML tree
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker_2}
function set_tickers_2(xml_tree::ETree)
    tickers = Dict{String, Ticker_2}()
    for tk_2_xml in find(xml_tree, "/RESPONSE/SYMBOLS2/SYMBOL2")
        tickers[tk_2.code] = tk_2 = Ticker_2(tk_2_xml)
    end
    return tickers
end

# set_ticker_changes()
# --------------
# Returns a collection of ticker changes
# INPUT: XML tree
# OUTPUT: Dict() of ticker changes of type ::Dict{String, TickerChange}
function set_ticker_changes(xml_tree::ETree)
    ticker_changes = Dict{String, TickerChange}()
    for tc_xml in find(xml_tree, "/RESPONSE/SYMBOLCHANGES/SYMBOLCHANGE")
        ticker_changes[tc.old_ticker_code * "_" * string(tc.date_time)] = tc = TickerChange(tc_xml)
    end
    return ticker_changes
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
