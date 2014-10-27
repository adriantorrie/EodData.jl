#=
	EodData Web Service Calls
=#

# ===================================
# Make functions available externally
export country_list, data_client_latest_version, data_formats, exchange_get, exchange_list,
		exchange_months, fundamental_list, login, login_2, membership, quote_get, quote_list,
		quote_list_2, quote_list_by_date, quote_list_by_date_2, quote_list_by_date_period,
		quote_list_by_date_period_2, split_list_by_exchange, split_list_by_symbol,
		symbol_changes_by_exchange, symbol_chart, symbol_get, symbol_history, symbol_history_period,
		symbol_history_period_by_date_range, symbol_list, symbol_list_2, technical_list,
		top_10_gains, top_10_losses, validate_access

# =========
# Functions

# country_list()
# --------------
# Returns a list of available countries.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of countries of type ::Dict{String, Country}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=CountryList
function country_list(token::String)
	call = "/CountryList"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_countries(xml_tree)
end

# data_client_latest_version()
# ----------------------------
# Returns the latest version information of Data Client.
# INPUT: Token (Login Token)
# OUTPUT: Date Client Version of type ::String
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataClientLatestVersion
function data_client_latest_version(token::String)
	call = "/DataClientLatestVersion"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return find(xml_tree, "/RESPONSE/VERSION[1]#string")
end

# data_formats()
# --------------
# Returns the list of data formats.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of DataFormats of the type ::Dict{String, DataFormat}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataFormats
function data_formats(token::String)
	call = "/DataFormats"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_data_formats(xml_tree)
end

# exchange_get()
# --------------
# Returns detailed information of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Exchange of type ::Exchange
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeGet
function exchange_get(token::String, exchange_code::String)
	call = "/ExchangeGet"
	args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return Exchange(find(xml_tree, "/RESPONSE/EXCHANGE[1]"))
end

# exchange_list()
# ---------------
# Returns a list of available exchanges.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of exchanges of the type ::Dict{String, Exchange}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeList
function exchange_list(token::String)
	call = "/ExchangeList"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_exchanges(xml_tree)

end

# exchange_months()
# -----------------
# Returns the number of Months history a user is allowed to download.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Number of Months as an ::Int
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeMonths
function exchange_months(token::String, exchange_code::String)
	call = "/ExchangeMonths"
	args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return int(find(xml_tree, "/RESPONSE/MONTHS[1]#string"))
end

# fundamental_list()
# ------------------
# Returns a complete list of fundamental data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of fundamentals of type ::Dict{String, Fundamental}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=FundamentalList
function fundamental_list(token::String, exchange_code::String)
	call = "/FundamentalList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_fundamentals(xml_tree)
end

# login()
# -------
# Login to EODData Financial Information Web Service. Used for Web Authentication.
# INPUT: Username, Password
# OUTPUT: Login Token, which is a field in the type ::LoginResponse
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login
function login(username::String, password::String)
	call = "/Login"
	args = ["Username"=>"$username", "Password"=>"$password"]
	xml_tree = get_response(call, args)

	validate_xml_login(xml_tree) && return LoginResponse(xml_tree)
end

# login_2()
# ---------
# Login to EODData Financial Information Web Service. Used for Application Authentication.
# INPUT: Username, Password, Version (Application Version)
# OUTPUT: Login Token, which is a field in the type ::LoginResponse
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login2
function login_2(username::String, password::String, version::String)
	call = "/Login"
	args = ["Username"=>"$username", "Password"=>"$password", "Version"=>"$version"]
	xml_tree = get_response(call, args)

	validate_xml_login(xml_tree) && return LoginResponse(xml_tree)
end

# membership()
# ------------
# Returns membership of user.
# INPUT: Token (Login Token)
# OUTPUT: Membership of type ::String
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Membership
function membership(token::String)
	call = "/Membership"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return find(xml_tree, "/RESPONSE/MEMBERSHIP[1]#string")
end

# quote_get()
# -----------
# Returns an end of day quote for a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), ticker (eg:"MSFT")
# OUTPUT: End of day quote of type ::Quote
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteGet
function quote_get(token::String, exchange::String, ticker::String)
	call = "/QuoteGet"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return Quote(find(xml_tree, "/RESPONSE/QUOTE[1]"))
end

# quote_list()
# ------------
# Returns a complete list of end of day quotes for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList
function quote_list(token::String, exchange::String)
	call = "/QuoteList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# quote_list_2()
# --------------
# Returns end of day quotes for a list of tickers of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Symbols (eg:"MSFT,INTC")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList2
function quote_list_2(token::String, exchange::String, tickers::String)
	call = "/QuoteList2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbols"=>"$tickers"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# quote_list_by_date()
# --------------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate
function quote_list_by_date(token::String, exchange::String, quote_date::String)
	call = "/QuoteListByDate"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# quote_list_by_date_2()
# ----------------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate2
function quote_list_by_date_2(token::String, exchange::String, quote_date::String)
	call = "/QuoteListByDate2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes_2(xml_tree)
end

# quote_list_by_date_period()
# ---------------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225"),
#		 Period (eg: "1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of end of period quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod
function quote_list_by_date_period(token::String, exchange::String, quote_date::String, period::String)
	call = "/QuoteListByDatePeriod"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# quote_list_by_date_period_2()
# -----------------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225"),
# Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of end of period quotes of type ::Dict{String, Quote_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod2
function quote_list_by_date_period_2(token::String, exchange::String, quote_date::String, period::String)
	call = "/QuoteListByDatePeriod2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes_2(xml_tree)
end

# split_list_by_exchange()
# ------------------------
# Returns a list of Splits of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of splits of type::Dict{String, Split}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListByExchange
function split_list_by_exchange(token::String, exchange::String)
	call = "/SplitListByExchange"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_splits(xml_tree)
end

# split_list_by_symbol()
# ----------------------
# Returns a list of splits of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT")
# OUTPUT: Dict() of splits of type::Dict{String, Split}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListBySymbol
function split_list_by_symbol(token::String, exchange::String, ticker::String)
	call = "/SplitListBySymbol"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_splits(xml_tree)
end

# symbol_changes_by_exchange()
# ----------------------------
# Returns a list of ticker changes of a given exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of ticker changes of type::Dict{String, TickerChange}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChangesByExchange
function symbol_changes_by_exchange(token::String, exchange::String)
	call = "/SymbolChangesByExchange"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_ticker_changes(xml_tree)
end

# symbol_chart()
# --------------
# Returns a URL to a chart image of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Ticker (eg:MSFT)
# OUTPUT: Chart URL
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChart
function symbol_chart(token::String, exchange::String, ticker::String)
	symbol_get(token, exchange, ticker)
	call = "/SymbolChart"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return find(xml_tree, "/RESPONSE/CHART[1]#string")
end

# symbol_get()
# ------------
# Returns detailed information of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT")
# OUTPUT: Ticker of type ::Ticker
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolGet
function symbol_get(token::String, exchange::String, ticker::String)
	call = "/SymbolGet"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return Ticker(find(xml_tree, "/RESPONSE/SYMBOL[1]"))
end

# symbol_history()
# ----------------
# Returns a list of historical end of day data of a specified symbol and specified start date up to today's date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT"), StartDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistory
function symbol_history(token::String, exchange::String, ticker::String, start_date::String)
	call = "/SymbolHistory"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker", "StartDate"=>"$start_date"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# symbol_history_period()
# -----------------------
# Returns a list of historical data of a specified symbol, specified date and specified period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Symbol (eg:"MSFT"), Date (format:yyyyMMdd eg:"20080225"),
# 		  Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistoryPeriod
function symbol_history_period(token::String, exchange::String, ticker::String, quote_date::String, period::String)
	call = "/SymbolHistoryPeriod"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker", "Date"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# symbol_history_period_by_date_range()
# -------------------------------------
# Returns a list of historical data of a specified symbol, specified date range and specified period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Symbol (eg:"MSFT"),
# 		  StartDate (format:yyyyMMdd eg:"20080225"), EndDate (format:yyyyMMdd eg:"20080225"),
# 		  Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of historical quotes of type Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistoryPeriodByDateRange
function symbol_history_period_by_date_range(token::String, exchange::String, ticker::String, start_date::String, end_date::String, period::String)
	call = "/SymbolHistoryPeriodByDateRange"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker",
			"StartDate"=>"$start_date", "EndDate"=>"$end_date","Period"=>"$period"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# symbol_list()
# -------------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList
function symbol_list(token::String, exchange::String)
	call = "/SymbolList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_tickers(xml_tree)
end

# symbol_list_2()
# ---------------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList2
function symbol_list_2(token::String, exchange::String)
	call = "/SymbolList2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_tickers_2(xml_tree)
end

# technical_list()
# ----------------
# Returns a complete list of technical data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of technical indicators for each ticker of type ::Dict{String, Technical}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=TechnicalList
function technical_list(token::String, exchange::String)
	call = "/TechnicalList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_technicals(xml_tree)
end

# top_10_gains()
# --------------
# Returns a list of the Top 10 Gains of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Gains
function top_10_gains(token::String, exchange::String)
	call = "/Top10Gains"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# top_10_losses()
# ---------------
# Returns a list of the Top 10 Losses of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Losses
function top_10_losses(token::String, exchange::String)
	call = "/Top10Losses"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	validate_xml(xml_tree) && return set_quotes(xml_tree)
end

# update_data_format()
# --------------------
# Update preferred Data Format
# INPUT: Token (Login Token), IncludeHeader, IncludeSuffix
# OUTPUT: List of DataFormats
# REFERENCE: http://ws.eoddata.com/data.asmx?op=UpdateDataFormat
# function update_data_format()
	# This function is not implemented
# end

# validate_access()
# -----------------
# Validate access for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225"),
# Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Boolean
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ValidateAccess
function validate_access(token::String, exchange::String, quote_date::String, period::String)
	call = "/ValidateAccess"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	return lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}"))) == "success" ? true : false
end
