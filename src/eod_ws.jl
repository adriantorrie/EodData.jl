# =========================
# EodData Web Service Calls

# ===================================
# Make functions available externally
export country_list, data_client_latest_version, data_formats, exchange_list, login

# =========
# Functions

# CountryList
# -----------
# Returns a list of available countries.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of countries of type ::Dict{String, String}
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
# OUTPUT: Date Client Version of type ::String
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataClientLatestVersion
function data_client_latest_version(token::String)
	if is(token, nothing)
		error("data_client_latest_version() failed: Missing value in parameter -> token::Sring")
	else
		call = "/DataClientLatestVersion"
		args = ["Token"=>"$token"]
		xml_tree = get_response(call, args)

		version = strip(find(xml_tree, "/RESPONSE/VERSION[1]").elements[1])

		return version
	end
end

# DataFormats
# -----------
# Returns the list of data formats.
# INPUT: Token (Login Token)
# OUTPUT: Dict() of DataFormats of the type ::Dict{String, DataFormat}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=DataFormats
function data_formats(token::String)
	if is(token, nothing)
		error("data_formats() failed: Missing value in parameter -> token::Sring")
	else
		call = "/DataFormats"
		args = ["Token"=>"$token"]
		xml_tree = get_response(call, args)

		# Shred xml_tree into a Dict{String, DataFormat}
		delimiters = [',', ';', ' ' ]
		formats = Dict{String, DataFormat}()
		for df in find(xml_tree, "/RESPONSE/DATAFORMATS/DATAFORMAT")
			# Initialise local
			format_header = []
			columns = Dict{Int, DataFormatColumn}()

			# Assign
			code::String = strip(get(df.attr,"Code",""))
			name::String = strip(get(df.attr,"Name",""))
			header_format::Vector{String} = convert(Array{String}, split(strip(get(df.attr,"Header","")), delimiters))
			date_format::String = strip(get(df.attr,"DateFormat",""))
			extension::String = strip(get(df.attr,"Extension",""))
			include_suffix::Bool = lowercase(strip(get(df.attr,"IncludeSuffix",""))) == "true" ? true : false
			tab_column_seperator::Bool = lowercase(strip(get(df.attr,"TabColumnSeperator","")))  == "true" ? true : false
			column_seperator::String = strip(get(df.attr,"ColumnSeperator",""))
			text_qualifier::String = strip(get(df.attr,"TextQualifier",""))
			filename_prefix::String = strip(get(df.attr,"FilenamePrefix",""))
			filename_exchange_code::Bool = lowercase(strip(get(df.attr,"FilenameExchangeCode",""))) == "true" ? true : false
			filename_date::Bool = lowercase(strip(get(df.attr,"FilenameDate",""))) == "true" ? true : false
			include_header_row::Bool = lowercase(strip(get(df.attr,"IncludeHeaderRow",""))) == "true" ? true : false
			hour_format::String = strip(get(df.attr,"HourFormat",""))
			datetime_seperator::String = strip(get(df.attr,"DateTimeSeperator",""))
			exchange_filename_format_date::String = strip(get(df.attr,"ExchangeFilenameFormatDate",""))
			exchange_filename_format_date_range::String = strip(get(df.attr,"ExchangeFilenameFormatDateRange",""))
			symbol_filename_format_date::String = strip(get(df.attr,"SymbolFilenameFormatDate",""))
			symbol_filename_format_date_range::String = strip(get(df.attr,"SymbolFilenameFormatDateRange",""))

			for col in find(df, "COLUMNS/DATAFORMAT_COLUMN")
				column_header::String = strip(get(col.attr,"Header",""))
				sort_order::Int = int(strip(get(col.attr,"SortOrder","")))
				data_format_code::String = strip(get(col.attr,"Code",""))
				data_format_name::String = strip(get(col.attr,"DataFormat",""))
				column_code::String = strip(get(col.attr,"ColumnCode",""))
				column_name::String = strip(get(col.attr,"ColumnName",""))
				column_type_id::Int = int(strip(get(col.attr,"ColumnTypeId","")))
				column_type::String = strip(get(col.attr,"ColumnType",""))

				columns[sort_order] = DataFormatColumn(column_header, sort_order, data_format_code, data_format_name, column_code, column_name, column_type_id, column_type)
			end

			formats[code] = DataFormat(code, name, header_format, date_format, extension, include_suffix, tab_column_seperator, column_seperator,
										text_qualifier, filename_prefix, filename_exchange_code, filename_date, include_header_row, hour_format,
										datetime_seperator, exchange_filename_format_date, exchange_filename_format_date_range,
										symbol_filename_format_date, symbol_filename_format_date_range, columns)
		end
		return formats
	end
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
# OUTPUT: Dict() of exchanges of the type ::Dict{String, Exchange}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeList
function exchange_list(token::String)
	if is(token, nothing)
		error("exchange_list() failed: Missing value in parameter -> token::Sring")
	else
		call = "/ExchangeList"
		args = ["Token"=>"$token"]
		xml_tree = get_response(call, args)

		# Shred xml_tree into a Dict{String, Exchange}
		date_format = "yyyy-mm-ddTHH:MM:SS"
		exchanges = Dict{String, Exchange}()
		for ex in find(xml_tree, "/RESPONSE/EXCHANGES/EXCHANGE")
			# Assign
			code::String = strip(get(ex.attr,"Code",""))
			name::String = strip(get(ex.attr,"Name",""))
			last_trade_date_time::DateTime  = DateTime(strip(get(ex.attr,"LastTradeDateTime","")), date_format)
			country_code::String = strip(get(ex.attr,"Country",""))
			currency_code::String = strip(get(ex.attr,"Currency",""))
			advances::Float64 = float(strip(get(ex.attr,"Advances","")))
			declines::Float64 = float(strip(get(ex.attr,"Declines","")))
			suffix::String = strip(get(ex.attr,"Suffix",""))
			time_zone::String = strip(get(ex.attr,"TimeZone",""))
			is_intraday::Bool = lowercase(strip(get(ex.attr,"IsIntraday",""))) == "true" ? true : false
			intraday_start_date::DateTime = DateTime(strip(get(ex.attr,"IntradayStartDate","")), date_format)
			has_intraday_product::Bool = lowercase(strip(get(ex.attr,"HasIntradayProduct",""))) == "true" ? true : false

			exchanges[code] = Exchange(code, name, last_trade_date_time, country_code, currency_code, advances, declines,
									   suffix, time_zone, is_intraday, intraday_start_date, has_intraday_product)
		end
		return exchanges
	end
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
# OUTPUT: Login Token, which is a field in the type ::LoginResponse
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login
function login(username::String, password::String)
	call = "/Login"
	args = ["Username"=>"$username", "Password"=>"$password"]
	xml_tree = get_response(call, args)

	# Set returned fields
	message = strip(find(xml_tree, "/LOGINRESPONSE[1]{Message}"))
	token = strip(find(xml_tree, "/LOGINRESPONSE[1]{Token}"))

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
