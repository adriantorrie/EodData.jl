# =========================
# EodData Web Service Calls

# ===================================
# Make functions available externally
export country_list, login

# =========
# Functions

# CountryList
# -----------
# Returns a list of available countries.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of countries
# REFERENCE: http://ws.eoddata.com/data.asmx?op=CountryList
function country_list(token::String)
	if token == nothing
		error("country_list() failed: Missing value in parameter -> token::Sring")
	else
		call = "/CountryList"
		args = ["Token"=>"$token"]
		xml_tree = get_response(call, args)

		# Shred xml_tree into a Dict()
		countries = Dict()
		for cb in find(xml_tree, "/RESPONSE/COUNTRIES/CountryBase")
			countries[strip(get(cb.attr,"Code",""))] = strip(get(cb.attr,"Name",""))
		end
		return countries
	end
end

# DataClientLatestVersion
# -----------------------
# Returns the latest version information of Data Client.
# INPUT: Token (Login Token)
# OUTPUT: Date Client Version
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataClientLatestVersion
function data_client_latest_version()
	# Type code here
end

# DataFormats
# -----------
# Returns the list of data formats.
# INPUT: Token (Login Token)
# OUTPUT: List of DataFormats
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataFormats
function data_formats()
	# Type code here
end

# ExchangeGet
# -----------
# Returns detailed information of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: Exchange
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeGet
function exchange_get()
	# Type code here
end

# ExchangeList
# ------------
# Returns a list of available exchanges.
# INPUT: Token (Login Token)
# OUTPUT: List of exchanges
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeList
function exchange_list()
	# Type code here
end

# ExchangeMonths
# --------------
# Returns the number of Months history a user is allowed to download.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: Number of Months
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeMonths
function exchange_months()
	# Type code here
end

# FundamentalList
# ---------------
# Returns a complete list of fundamental data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of fundamentals
# REFERENCE: http://ws.eoddata.com/data.asmx?op=FundamentalList
function fundamental_list()
	# Type code here
end

# Login
# -----
# Login to EODData Financial Information Web Service. Used for Web Authentication.
# INPUT: Username, Password
# OUTPUT: Login Token
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login
function login(username::String, password::String)
	call = "/Login"
	args = ["Username"=>"$username", "Password"=>"$password"]
	xml_tree = get_response(call, args)

	# Set returned fields
	message = find(xml_tree, "/LOGINRESPONSE[1]{Message}")
	token = find(xml_tree, "/LOGINRESPONSE[1]{Token}")

	return LoginResponse(message,token)
end

# Login2
# ------
# Login to EODData Financial Information Web Service. Used for Application Authentication.
# INPUT: Username, Password, Version (Application Version)
# OUTPUT: Login Token
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login2
function login_2()
	# Type code here
end

# Membership
# ----------
# Returns membership of user.
# INPUT: Token (Login Token)
# OUTPUT: Membership
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Membership
function membership()
	# Type code here
end

# QuoteGet
# --------
# Returns an end of day quote for a specific symbol.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT)
# OUTPUT: End of day quote
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteGet
function quote_get()
	# Type code here
end

# QuoteList
# ---------
# Returns a complete list of end of day quotes for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of end of day quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList
function quote_list()
	# Type code here
end

# QuoteList2
# ----------
# Returns end of day quotes for a list of symbols of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbols (eg:MSFT,INTC)
# OUTPUT: List of end of day quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList2
function quote_list_2()
	# Type code here
end

# QuoteListByDate
# ---------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), QuoteDate (format:yyyyMMdd eg:20080225)
# OUTPUT: List of end of day quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate
function quote_list_by_date()
	# Type code here
end

# QuoteListByDate2
# ----------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), QuoteDate (format:yyyyMMdd eg:20080225)
# OUTPUT: List of end of day quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate2
function quote_list_by_date_2()
	# Type code here
end

# QuoteListByDatePeriod
# ---------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), QuoteDate (format:yyyyMMdd eg:20080225), Period (1, 5, 10, 15, 30, h, d, w, m)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod
function quote_list_by_date_period()
	# Type code here
end

# QuoteListByDatePeriod2
# ----------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), QuoteDate (format:yyyyMMdd eg:20080225), Period (1, 5, 10, 15, 30, h, d, w, m)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod2
function quote_list_by_date_period_2()
	# Type code here
end

# SplitListByExchange
# -------------------
# Returns a list of Splits of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of splits
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListByExchange
function split_list_by_exchange()
	# Type code here
end

# SplitListBySymbol
# -----------------
# Returns a list of Splits of a specific symbol.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT)
# OUTPUT: List of splits
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListBySymbol
function split_list_by_symbol()
	# Type code here
end

# SymbolChangesByExchange
# -----------------------
# Returns a list of symbol changes of a given exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of symbol changes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChangesByExchange
function symbol_changes_by_exchange()
	# Type code here
end

# SymbolChart
# -----------
# Returns a URL to a chart image of a specific symbol.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT)
# OUTPUT: Chart URL
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChart
function symbol_chart()
	# Type code here
end

# SymbolGet
# ---------
# Returns detailed information of a specific symbol.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT)
# OUTPUT: Symbol
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolGet
function symbol_get()
	# Type code here
end

# SymbolHistory
# -------------
# Returns a list of historical end of day data of a specified symbol and specified start date up to today's date.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT), StartDate (format:yyyyMMdd eg:20080225)
# OUTPUT: List of historical end of day quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistory
function symbol_history()
	# Type code here
end

# SymbolHistoryPeriod
# -------------------
# Returns a list of historical data of a specified symbol, specified date and specified period.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT), Date (format:yyyyMMdd eg:20080225), Period (1, 5, 10, 15, 30, h, d, w, m)
# OUTPUT: List of historical quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistoryPeriod
function symbol_history_period()
	# Type code here
end

# SymbolHistoryPeriodByDateRange
# ------------------------------
# Returns a list of historical data of a specified symbol, specified date range and specified period.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Symbol (eg:MSFT), StartDate (format:yyyyMMdd eg:20080225), EndDate (format:yyyyMMdd eg:20080225), Period (1, 5, 10, 15, 30, h, d, w, m)
# OUTPUT: List of historical quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistoryPeriodByDateRange
function symbol_history_period_by_date_range()
	# Type code here
end

# SymbolList
# ----------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of symbols
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList
function symbol_list()
	# Type code here
end

# SymbolList2
# -----------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of symbols
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList2
function symbol_list_2()
	# Type code here
end

# TechnicalList
# -------------
# Returns a complete list of technical data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=TechnicalList
function technical_list()
	# Type code here
end

# Top10Gains
# ----------
# Returns a list of the Top 10 Gains of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Gains
function top_10_gains()
	# Type code here
end

# Top10Losses
# -----------
# Returns a list of the Top 10 Losses of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Losses
function top_10_losses()
	# Type code here
end

# UpdateDataFormat
# ----------------
# Update preferred Data Format
# INPUT: Token (Login Token), IncludeHeader, IncludeSuffix
# OUTPUT: List of DataFormats
# REFERENCE: http://ws.eoddata.com/data.asmx?op=UpdateDataFormat
function update_data_format()
	# Type code here
end

# ValidateAccess
# --------------
# Validate access for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), QuoteDate (format:yyyyMMdd eg:20080225), Period (1, 5, 10, 15, 30, h, d, w, m)
# OUTPUT: RESPONSE
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ValidateAccess
function validate_access()
	# Type code here
end
