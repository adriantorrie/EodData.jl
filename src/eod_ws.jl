#=
	EodData Web Service Calls
=#

# ==================
# Internal variables
const DATETIMEFORMAT_SS = "yyyy-mm-ddTHH:MM:SS"
const DATETIMEFORMAT_MS = "yyyy-mm-ddTHH:MM:SS.ss"
const HEADER_DELIMITERS = [',', ';', ' ']

# ===================================
# Make functions available externally
export country_list, data_client_latest_version, data_formats, exchange_get, exchange_list,
		exchange_months, fundamental_list, login, login_2, membership, quote_get, quote_list,
		quote_list_2, quote_list_by_date, quote_list_by_date_2, quote_list_by_date_period,
		quote_list_by_date_period_2, split_list_by_exchange, split_list_by_symbol,
		symbol_changes_by_exchange, symbol_chart, symbol_get, symbol_history, symbol_history_period,
		symbol_history_period_by_date_range, symbol_list, symbol_list_2, technical_list,
		top_10_gains, top_10_losses

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
		countries = Dict{String, String}()
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

		return strip(find(xml_tree, "/RESPONSE/VERSION[1]").elements[1])
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
		formats = Dict{String, DataFormat}()
		for df in find(xml_tree, "/RESPONSE/DATAFORMATS/DATAFORMAT")
			# Initialise local
			format_header = []
			columns = Dict{Int, DataFormatColumn}()

			# Assign
			code::String = strip(get(df.attr,"Code",""))
			name::String = strip(get(df.attr,"Name",""))
			header_format::Vector{String} = convert(Array{String}, split(strip(get(df.attr,"Header","")), HEADER_DELIMITERS))
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
			ticker_filename_format_date::String = strip(get(df.attr,"SymbolFilenameFormatDate",""))
			ticker_filename_format_date_range::String = strip(get(df.attr,"SymbolFilenameFormatDateRange",""))

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

			# Add format to Dict
			formats[code] = DataFormat(code, name, header_format, date_format, extension, include_suffix, tab_column_seperator, column_seperator,
										text_qualifier, filename_prefix, filename_exchange_code, filename_date, include_header_row, hour_format,
										datetime_seperator, exchange_filename_format_date, exchange_filename_format_date_range,
										ticker_filename_format_date, ticker_filename_format_date_range, columns)
		end
		return formats
	end
end # data_formats

# ExchangeGet
# -----------
# Returns detailed information of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Exchange
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeGet
function exchange_get(token::String, exchange_code::String)
	if is(token, nothing)
		error("exchange_list() failed: Missing value in parameter -> token::Sring")
	elseif exchange_code == "" || is(exchange_code, nothing)
		error("exchange_list() failed: Missing value in parameter -> exchange_code::Sring")
	else
		call = "/ExchangeGet"
		args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
		xml_tree = get_response(call, args)

		# Shred xml_tree into a Dict{String, Exchange}
		ex = find(xml_tree, "/RESPONSE/EXCHANGE")[1]
		# Assign
		code::String = strip(get(ex.attr,"Code",""))
		name::String = strip(get(ex.attr,"Name",""))
		last_trade_date_time::DateTime  = DateTime(strip(get(ex.attr,"LastTradeDateTime","")), DATETIMEFORMAT_SS)
		country_code::String = strip(get(ex.attr,"Country",""))
		currency_code::String = strip(get(ex.attr,"Currency",""))
		advances::Float64 = float(strip(get(ex.attr,"Advances","")))
		declines::Float64 = float(strip(get(ex.attr,"Declines","")))
		suffix::String = strip(get(ex.attr,"Suffix",""))
		time_zone::String = strip(get(ex.attr,"TimeZone",""))
		is_intraday::Bool = lowercase(strip(get(ex.attr,"IsIntraday",""))) == "true" ? true : false
		intraday_start_date::DateTime = DateTime(strip(get(ex.attr,"IntradayStartDate","")), DATETIMEFORMAT_SS)
		has_intraday_product::Bool = lowercase(strip(get(ex.attr,"HasIntradayProduct",""))) == "true" ? true : false

		return exchange = Exchange(code, name, last_trade_date_time, country_code, currency_code, advances, declines,
								   suffix, time_zone, is_intraday, intraday_start_date, has_intraday_product)
	end
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
		exchanges = Dict{String, Exchange}()
		for ex in find(xml_tree, "/RESPONSE/EXCHANGES/EXCHANGE")
			# Assign
			code::String = strip(get(ex.attr,"Code",""))
			name::String = strip(get(ex.attr,"Name",""))
			last_trade_date_time::DateTime  = DateTime(strip(get(ex.attr,"LastTradeDateTime","")), DATETIMEFORMAT_SS)
			country_code::String = strip(get(ex.attr,"Country",""))
			currency_code::String = strip(get(ex.attr,"Currency",""))
			advances::Float64 = float(strip(get(ex.attr,"Advances","")))
			declines::Float64 = float(strip(get(ex.attr,"Declines","")))
			suffix::String = strip(get(ex.attr,"Suffix",""))
			time_zone::String = strip(get(ex.attr,"TimeZone",""))
			is_intraday::Bool = lowercase(strip(get(ex.attr,"IsIntraday",""))) == "true" ? true : false
			intraday_start_date::DateTime = DateTime(strip(get(ex.attr,"IntradayStartDate","")), DATETIMEFORMAT_SS)
			has_intraday_product::Bool = lowercase(strip(get(ex.attr,"HasIntradayProduct",""))) == "true" ? true : false

			# Add exchange to Dict
			exchanges[code] = Exchange(code, name, last_trade_date_time, country_code, currency_code, advances, declines,
									   suffix, time_zone, is_intraday, intraday_start_date, has_intraday_product)
		end
		return exchanges
	end
end

# ExchangeMonths
# --------------
# Returns the number of Months history a user is allowed to download.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Number of Months as an ::Int
# REFERENCE: http://ws.eoddata.com/data.asmx?op=ExchangeMonths
function exchange_months(token::String, exchange_code::String)
	if is(token, nothing)
		error("exchange_list() failed: Missing value in parameter -> token::Sring")
	elseif exchange_code == "" || is(exchange_code, nothing)
		error("exchange_list() failed: Missing value in parameter -> exchange_code::Sring")
	else
		call = "/ExchangeMonths"
		args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
		xml_tree = get_response(call, args)

		return int(strip(find(xml_tree, "/RESPONSE/MONTHS[1]").elements[1]))
	end
end

# FundamentalList
# ---------------
# Returns a complete list of fundamental data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of fundamentals of type ::Dict{String, Fundamental}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=FundamentalList
function fundamental_list(token::String, exchange_code::String)
	if is(token, nothing)
		error("exchange_list() failed: Missing value in parameter -> token::Sring")
	elseif exchange_code == "" || is(exchange_code, nothing)
		error("exchange_list() failed: Missing value in parameter -> exchange_code::Sring")
	else
		call = "/FundamentalList"
		args = ["Token"=>"$token", "Exchange"=>"$exchange_code"]
		xml_tree = get_response(call, args)

		# Shred xml_tree into a ::Dict{String, Fundamental}
		fundamentals = Dict{String, Fundamental}()
		for fl in find(xml_tree, "/RESPONSE/FUNDAMENTALS/FUNDAMENTAL")
			# Assign
			ticker_code::String = strip(get(fl.attr,"Symbol",""))
			name::String = strip(get(fl.attr,"Name",""))
			description::String = strip(get(fl.attr,"Description",""))
			date_time::DateTime = DateTime(strip(get(fl.attr,"DateTime","")), DATETIMEFORMAT_SS)
			industry::String = strip(get(fl.attr,"Industry",""))
			sector::String = strip(get(fl.attr,"Sector",""))
			share_float::Float64 = float(strip(get(fl.attr,"Shares","")))
			market_cap::Float64 = float(strip(get(fl.attr,"MarketCap","")))
			pe_ratio::Float64 = float(strip(get(fl.attr,"PE","")))
			earnings_per_share::Float64 = float(strip(get(fl.attr,"EPS","")))
			net_tangible_assets::Float64 = float(strip(get(fl.attr,"NTA","")))
			dividend_yield::Float64 = float(strip(get(fl.attr,"DivYield","")))
			dividend::Float64 = float(strip(get(fl.attr,"Dividend","")))
			dividend_date::DateTime = DateTime(strip(get(fl.attr,"DividendDate","")), DATETIMEFORMAT_SS)
			dividend_per_share::Float64 = float(strip(get(fl.attr,"DPS","")))
			imputation_credits::Float64 = float(strip(get(fl.attr,"ImputationCredits","")))
			ebitda::Float64 = float(strip(get(fl.attr,"EBITDA","")))
			peg_ratio::Float64 = float(strip(get(fl.attr,"PEG","")))
			ps_ratio::Float64 = float(strip(get(fl.attr,"PtS","")))
			pb_ratio::Float64 = float(strip(get(fl.attr,"PtB","")))
			yield::Float64 = float(strip(get(fl.attr,"Yield","")))

			# Add fundamental to Dict
			fundamentals[ticker_code] = Fundamental(ticker_code, name, description, date_time, industry,
													sector, share_float, market_cap, pe_ratio, earnings_per_share,
													net_tangible_assets, dividend_yield, dividend, dividend_date,
													dividend_per_share, imputation_credits, ebitda, peg_ratio,
													ps_ratio, pb_ratio, yield)
		end
		return fundamentals
	end
end # fundamental_list

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
# OUTPUT: Login Token, which is a field in the type ::LoginResponse
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Login2
function login_2(username::String, password::String, version::String)
	call = "/Login"
	args = ["Username"=>"$username", "Password"=>"$password", "Version"=>"$version"]
	xml_tree = get_response(call, args)

	# Set returned fields
	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("membership() failed with message returned of: $message")
	else
 		message = strip(find(xml_tree, "/LOGINRESPONSE[1]{Message}"))
		token = strip(find(xml_tree, "/LOGINRESPONSE[1]{Token}"))

		return LoginResponse(message,token)
	end
end

# Membership
# ----------
# Returns membership of user.
# INPUT: Token (Login Token)
# OUTPUT: Membership of type ::String
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Membership
function membership(token::String)
	call = "/Membership"
	args = ["Token"=>"$token"]
	xml_tree = get_response(call, args)

	# Set returned fields
	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("membership() failed with message returned of: $message")
	else
		return string(strip(find(xml_tree, "/RESPONSE/MEMBERSHIP[1]").elements[1]))
	end
end

# QuoteGet
# --------
# Returns an end of day quote for a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), ticker (eg:"MSFT")
# OUTPUT: End of day quote of type ::Quote
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteGet
function quote_get(token::String, exchange::String, ticker::String)
	call = "/QuoteGet"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_get() failed with message returned of: $message")
	else
		# Shred xml_tree into a ::Quote
		qt = find(xml_tree, "/RESPONSE/QUOTE[1]")
		# Assign
		ticker_code::String = strip(get(qt.attr,"Symbol",""))
		description::String = strip(get(qt.attr,"Description",""))
		name::String = strip(get(qt.attr,"Name",""))
		date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_MS)
		open::Float64 = float(strip(get(qt.attr,"Open","")))
		high::Float64 = float(strip(get(qt.attr,"High","")))
		low::Float64 = float(strip(get(qt.attr,"Low","")))
		close::Float64 = float(strip(get(qt.attr,"Close","")))
		volume::Float64 = float(strip(get(qt.attr,"Volume","")))
		open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
		previous::Float64 = float(strip(get(qt.attr,"Previous","")))
		change::Float64 = float(strip(get(qt.attr,"Change","")))
		simple_return::Float64 = change / previous
		bid::Float64 = float(strip(get(qt.attr,"Bid","")))
		ask::Float64 = float(strip(get(qt.attr,"Ask","")))
		previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
		next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
		modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

		return Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
					 previous, change, simple_return, bid, ask, previous_close, next_open, modified)
	end
end

# QuoteList
# ---------
# Returns a complete list of end of day quotes for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList
function quote_list(token::String, exchange::String)
	call = "/QuoteList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_MS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code] = Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
										previous, change, simple_return, bid, ask, previous_close, next_open, modified)
		end
		return quotes
	end
end

# QuoteList2
# ----------
# Returns end of day quotes for a list of tickers of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Symbols (eg:"MSFT,INTC")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteList2
function quote_list_2(token::String, exchange::String, tickers::String)
	call = "/QuoteList2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbols"=>"$tickers"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list_2() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_MS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code] = Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
										previous, change, simple_return, bid, ask, previous_close, next_open, modified)
		end
		return quotes
	end
end

# QuoteListByDate
# ---------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate
function quote_list_by_date(token::String, exchange::String, quote_date::String)
	call = "/QuoteListByDate"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list_by_date() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_MS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code] = Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
										previous, change, simple_return, bid, ask, previous_close, next_open, modified)
		end
		return quotes
	end
end

# QuoteListByDate2
# ----------------
# Returns a complete list of end of day quotes for an entire exchange and a specific date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of end of day quotes of type ::Dict{String, Quote_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDate2
function quote_list_by_date_2(token::String, exchange::String, quote_date::String)
	call = "/QuoteListByDate2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list_by_date_2() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote_2}
		quotes = Dict{String, Quote_2}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES2/QUOTE2")
			# Assign
			ticker_code::String = strip(get(qt.attr,"s",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"d","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"o","")))
			high::Float64 = float(strip(get(qt.attr,"h","")))
			low::Float64 = float(strip(get(qt.attr,"l","")))
			close::Float64 = float(strip(get(qt.attr,"c","")))
			volume::Float64 = float(strip(get(qt.attr,"v","")))
			open_interest::Float64 = float(strip(get(qt.attr,"i","")))
			bid::Float64 = float(strip(get(qt.attr,"b","")))
			ask::Float64 = float(strip(get(qt.attr,"a","")))

			quotes[ticker_code] = Quote_2(ticker_code, date_time, open, high, low, close, volume, open_interest, bid, ask,)
		end
		return quotes
	end
end

# QuoteListByDatePeriod
# ---------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225"),
#		 Period (eg: "1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of end of period quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod
function quote_list_by_date_period(token::String, exchange::String, quote_date::String, period::String)
	call = "/QuoteListByDatePeriod"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list_by_date_period() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_SS)

			quotes[ticker_code * "_" * string(date_time)] = Quote(ticker_code, description, name, date_time, open,
																  high, low, close, volume, open_interest,
																  previous, change, simple_return, bid, ask,
																  previous_close, next_open, modified)
		end
		return quotes
	end
end

# QuoteListByDatePeriod2
# ----------------------
# Returns a complete list of end of day quotes for an entire exchange, specific date, and specific period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), QuoteDate (format:yyyyMMdd eg:"20080225"),
# Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of end of period quotes of type ::Dict{String, Quote_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=QuoteListByDatePeriod2
function quote_list_by_date_period_2(token::String, exchange::String, quote_date::String, period::String)
	call = "/QuoteListByDatePeriod2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "QuoteDate"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("quote_list_by_date_period_2() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote_2}
		quotes = Dict{String, Quote_2}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES2/QUOTE2")
			# Assign
			ticker_code::String = strip(get(qt.attr,"s",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"d","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"o","")))
			high::Float64 = float(strip(get(qt.attr,"h","")))
			low::Float64 = float(strip(get(qt.attr,"l","")))
			close::Float64 = float(strip(get(qt.attr,"c","")))
			volume::Float64 = float(strip(get(qt.attr,"v","")))
			open_interest::Float64 = float(strip(get(qt.attr,"i","")))
			bid::Float64 = float(strip(get(qt.attr,"b","")))
			ask::Float64 = float(strip(get(qt.attr,"a","")))

			quotes[ticker_code] = Quote_2(ticker_code, date_time, open, high, low, close, volume, open_interest, bid, ask,)
		end
		return quotes
	end
end

# SplitListByExchange
# -------------------
# Returns a list of Splits of a specific exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of splits of type::Dict{String, Split}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListByExchange
function split_list_by_exchange(token::String, exchange::String)
	call = "/SplitListByExchange"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("split_list_by_exchange() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Split}
		splits = Dict{String, Split}()
		for sp in find(xml_tree, "/RESPONSE/SPLITS/SPLIT")
			# Assign
			exchange_code::String = strip(get(sp.attr,"Exchange",""))
			ticker_code::String = strip(get(sp.attr,"Symbol",""))
			date_time::DateTime = DateTime(strip(get(sp.attr,"DateTime","")), DATETIMEFORMAT_SS)
			ratio::String = strip(get(sp.attr,"Ratio",""))
			price_multiplier::Float64 = float(strip(split(ratio, "-")[2])) / float(strip(split(ratio, "-")[1]))
			share_float_multiplier::Float64 = float(strip(split(ratio, "-")[1])) / float(strip(split(ratio, "-")[2]))
			is_reverse_split::Bool = price_multiplier > 1.0 ? true : false

			splits[ticker_code * "_" * string(date_time)] = Split(exchange_code, ticker_code, date_time, ratio,
																  price_multiplier, share_float_multiplier,
																  is_reverse_split)
		end
		return splits
	end
end

# SplitListBySymbol
# -----------------
# Returns a list of Splits of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT")
# OUTPUT: Dict() of splits of type::Dict{String, Split}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SplitListByticker
function split_list_by_symbol(token::String, exchange::String, ticker::String)
	call = "/SplitListBySymbol"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("split_list_by_exchange() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Split}
		splits = Dict{String, Split}()
		for sp in find(xml_tree, "/RESPONSE/SPLITS/SPLIT")
			# Assign
			exchange_code::String = strip(get(sp.attr,"Exchange",""))
			ticker_code::String = strip(get(sp.attr,"Symbol",""))
			date_time::DateTime = DateTime(strip(get(sp.attr,"DateTime","")), DATETIMEFORMAT_SS)
			ratio::String = strip(get(sp.attr,"Ratio",""))
			price_multiplier::Float64 = float(strip(split(ratio, "-")[2])) / float(strip(split(ratio, "-")[1]))
			share_float_multiplier::Float64 = float(strip(split(ratio, "-")[1])) / float(strip(split(ratio, "-")[2]))
			is_reverse_split::Bool = price_multiplier > 1.0 ? true : false

			splits[ticker_code * "_" * string(date_time)] = Split(exchange_code, ticker_code, date_time, ratio,
																  price_multiplier, share_float_multiplier,
																  is_reverse_split)
		end
		return splits
	end
end

# SymbolChangesByExchange
# -----------------------
# Returns a list of ticker changes of a given exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of ticker changes of type::Dict{String, TickerChange}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChangesByExchange
function symbol_changes_by_exchange(token::String, exchange::String)
	call = "/SymbolChangesByExchange"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_changes_by_exchange() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, TickerChange}
		ticker_changes = Dict{String, TickerChange}()
		for sc in find(xml_tree, "/RESPONSE/SYMBOLCHANGES/SYMBOLCHANGE")
			# Assign
			old_exchange_code::String = strip(get(sc.attr,"ExchangeCode",""))
			new_exchange_code::String = strip(get(sc.attr,"NewExchangeCode",""))
			old_ticker_code::String = strip(get(sc.attr,"OldSymbol",""))
			new_ticker_code::String = strip(get(sc.attr,"NewSymbol",""))
			date_time::DateTime = DateTime(strip(get(sc.attr,"DateTime","")), DATETIMEFORMAT_SS)
			is_change_of_exchange_code::Bool = old_exchange_code != new_exchange_code ? true : false
			is_change_of_ticker_code::Bool = old_ticker_code != new_ticker_code ? true : false

			ticker_changes[old_ticker_code * "_" * string(date_time)] =
				TickerChange(old_exchange_code, new_exchange_code, old_ticker_code, new_ticker_code,
							 date_time, is_change_of_exchange_code, is_change_of_ticker_code)
		end
		return ticker_changes
	end
end

# SymbolChart
# -----------
# Returns a URL to a chart image of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ), Ticker (eg:MSFT)
# OUTPUT: Chart URL
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolChart
function symbol_chart(token::String, exchange::String, ticker::String)
	call = "/SymbolChart"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_chart() failed with message returned of: $message")
	else
		# URL
		return find(xml_tree, "/RESPONSE/CHART[1]#string")
	end

end

# SymbolGet
# ---------
# Returns detailed information of a specific ticker.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT")
# OUTPUT: Ticker of type ::Ticker
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolGet
function symbol_get(token::String, exchange::String, ticker::String)
	call = "/SymbolGet"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_get() failed with message returned of: $message")
	else
		# Shred xml_tree into a ::Ticker
		sy = find(xml_tree, "/RESPONSE/SYMBOL[1]")
		# Assign
		code::String = strip(get(sy.attr,"Code",""))
		name::String = strip(get(sy.attr,"Name",""))
		long_name::String = strip(get(sy.attr,"LongName",""))
		date_time::DateTime = DateTime(strip(get(sy.attr,"DateTime","")), DATETIMEFORMAT_SS)

		return Ticker(code, name, long_name, date_time)
	end
end

# SymbolHistory
# -------------
# Returns a list of historical end of day data of a specified symbol and specified start date up to today's date.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Ticker (eg:"MSFT"), StartDate (format:yyyyMMdd eg:"20080225")
# OUTPUT: Dict() of quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistory
function symbol_history(token::String, exchange::String, ticker::String, start_date::String)
	call = "/SymbolHistory"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker", "StartDate"=>"$start_date"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_history() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code * "_" * string(date_time)] = Quote(ticker_code, description, name, date_time, open,
																  high, low, close, volume, open_interest,
																  previous, change, simple_return, bid, ask,
																  previous_close, next_open, modified)
		end
		return quotes
	end
end

# SymbolHistoryPeriod
# -------------------
# Returns a list of historical data of a specified symbol, specified date and specified period.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ"), Symbol (eg:"MSFT"), Date (format:yyyyMMdd eg:"20080225"),
# 		  Period ("1", "5", "10", "15", "30", "h", "d", "w", "m")
# OUTPUT: Dict() of quotes of type ::Dict{String, Quote}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolHistoryPeriod
function symbol_history_period(token::String, exchange::String, ticker::String, quote_date::String, period::String)
	call = "/SymbolHistoryPeriod"
	args = ["Token"=>"$token", "Exchange"=>"$exchange", "Symbol"=>"$ticker", "Date"=>"$quote_date", "Period"=>"$period"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_history_period() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_SS)

			quotes[ticker_code * "_" * string(date_time)] = Quote(ticker_code, description, name, date_time, open,
																  high, low, close, volume, open_interest,
																  previous, change, simple_return, bid, ask,
																  previous_close, next_open, modified)
		end
		return quotes
	end
end

# SymbolHistoryPeriodByDateRange
# ------------------------------
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

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_history_period_by_date_range() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
 			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code * "_" * string(date_time)] = Quote(ticker_code, description, name, date_time, open,
																  high, low, close, volume, open_interest,
																  previous, change, simple_return, bid, ask,
																  previous_close, next_open, modified)
 		end
		return quotes
	end
end

# SymbolList
# ----------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList
function symbol_list(token::String, exchange::String)
	call = "/SymbolList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_list() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Ticker}
		tickers = Dict{String, Ticker}()
		for sy in find(xml_tree, "/RESPONSE/SYMBOLS/SYMBOL")
			# Assign
			code::String = strip(get(sy.attr,"Code",""))
			name::String = strip(get(sy.attr,"Name",""))
			long_name::String = strip(get(sy.attr,"LongName",""))
			date_time::DateTime = DateTime(strip(get(sy.attr,"DateTime","")), DATETIMEFORMAT_SS)

			tickers[code] = Ticker(code, name, long_name, date_time)
		end
		return  tickers
	end
end

# SymbolList2
# -----------
# Returns a list of symbols of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: Dict() of tickers of type ::Dict{String, Ticker_2}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=SymbolList2
function symbol_list_2(token::String, exchange::String)
	call = "/SymbolList2"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("symbol_list_2() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Ticker_2}
		tickers = Dict{String, Ticker_2}()
		for sy in find(xml_tree, "/RESPONSE/SYMBOLS2/SYMBOL2")
			# Assign
			code::String = strip(get(sy.attr,"c",""))
			name::String = strip(get(sy.attr,"n",""))

			tickers[code] = Ticker_2(code, name)
		end
		return  tickers
	end
end

# TechnicalList
# -------------
# Returns a complete list of technical data for an entire exchange.
# INPUT: Token (Login Token), Exchange (eg: "NASDAQ")
# OUTPUT: Dict() of technical indicators for each ticker of type ::Dict{String, Technical}
# REFERENCE: http://ws.eoddata.com/data.asmx?op=TechnicalList
function technical_list(token::String, exchange::String)
	call = "/TechnicalList"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("technical_list() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Ticker_2}
		technicals = Dict{String, Technical}()
		for tc in find(xml_tree, "/RESPONSE/TECHNICALS/TECHNICAL")
			# Assign
			ticker_code::String = strip(get(tc.attr,"Symbol",""))
			name::String = strip(get(tc.attr,"Name",""))
			description::String = strip(get(tc.attr,"Description",""))
			date_time::DateTime = DateTime(strip(get(tc.attr,"DateTime","")), DATETIMEFORMAT_SS)
			previous::Float64 = float(strip(get(tc.attr,"Previous","")))
			change::Float64 = float(strip(get(tc.attr,"Change","")))
			ma_1::Float64 = float(strip(get(tc.attr,"MA1","")))
			ma_2::Float64 = float(strip(get(tc.attr,"MA2","")))
			ma_5::Float64 = float(strip(get(tc.attr,"MA5","")))
			ma_20::Float64 = float(strip(get(tc.attr,"MA20","")))
			ma_50::Float64 = float(strip(get(tc.attr,"MA50","")))
			ma_100::Float64 = float(strip(get(tc.attr,"MA100","")))
			ma_200::Float64 = float(strip(get(tc.attr,"MA200","")))
			ma_percent::Float64 = float(strip(get(tc.attr,"MAPercent","")))
			ma_return::Float64 = float(strip(get(tc.attr,"MAReturn","")))
			volume_change::Float64 = float(strip(get(tc.attr,"VolumeChange","")))
			three_month_change::Float64 = float(strip(get(tc.attr,"ThreeMonthChange","")))
			six_month_change::Float64 = float(strip(get(tc.attr,"SixMonthChange","")))
			week_high::Float64 = float(strip(get(tc.attr,"WeekHigh","")))
			week_low::Float64 = float(strip(get(tc.attr,"WeekLow","")))
			week_change::Float64 = float(strip(get(tc.attr,"WeekChange","")))
			avg_week_change::Float64 = float(strip(get(tc.attr,"AvgWeekChange","")))
			avg_week_volume::Float64 = float(strip(get(tc.attr,"AvgWeekVolume","")))
			week_volume::Float64 = float(strip(get(tc.attr,"WeekVolume","")))
			month_high::Float64 = float(strip(get(tc.attr,"MonthHigh","")))
			month_low::Float64 = float(strip(get(tc.attr,"MonthLow","")))
			month_change::Float64 = float(strip(get(tc.attr,"MonthChange","")))
			avg_month_change::Float64 = float(strip(get(tc.attr,"AvgMonthChange","")))
			avg_month_volume::Float64 = float(strip(get(tc.attr,"AvgMonthVolume","")))
			month_volume::Float64 = float(strip(get(tc.attr,"MonthVolume","")))
			year_high::Float64 = float(strip(get(tc.attr,"YearHigh","")))
			year_low::Float64 = float(strip(get(tc.attr,"YearLow","")))
			year_change::Float64 = float(strip(get(tc.attr,"YearChange","")))
			avg_year_change::Float64 = float(strip(get(tc.attr,"AvgYearChange","")))
			avg_year_volume::Float64 = float(strip(get(tc.attr,"AvgYearVolume","")))
			ytd_change::Float64 = float(strip(get(tc.attr,"YTDChange","")))
			rsi_14::Float64 = float(strip(get(tc.attr,"RSI14","")))
			sto_9::Float64 = float(strip(get(tc.attr,"STO9","")))
			wpr_14::Float64 = float(strip(get(tc.attr,"WPR14","")))
			mtm_14::Float64 = float(strip(get(tc.attr,"MTM14","")))
			roc_14::Float64 = float(strip(get(tc.attr,"ROC14","")))
			ptc::Float64 = float(strip(get(tc.attr,"PTC","")))
			sar::Float64 = float(strip(get(tc.attr,"SAR","")))
			volatility::Float64 = float(strip(get(tc.attr,"Volatility","")))
			liquidity::Float64 = float(strip(get(tc.attr,"Liquidity","")))

			technicals[ticker_code] = Technical(ticker_code, name, description, date_time, previous, change,
												ma_1, ma_2, ma_5, ma_20, ma_50, ma_100, ma_200, ma_percent,
												ma_return, volume_change, three_month_change, six_month_change,
												week_high, week_low, week_change, avg_week_change, avg_week_volume,
												week_volume, month_high, month_low, month_change, avg_month_change,
												avg_month_volume, month_volume, year_high, year_low, year_change,
												avg_year_change, avg_year_volume, ytd_change, rsi_14, sto_9,
												wpr_14, mtm_14, roc_14, ptc, sar, volatility, liquidity)
		end
		return  technicals
	end
end

# Top10Gains
# ----------
# Returns a list of the Top 10 Gains of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Gains
function top_10_gains(token::String, exchange::String)
	call = "/Top10Gains"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("top_10_gains() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code] = Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
										previous, change, simple_return, bid, ask, previous_close, next_open, modified)
		end
		return quotes
	end
end

# Top10Losses
# -----------
# Returns a list of the Top 10 Losses of a specified exchange.
# INPUT: Token (Login Token), Exchange (eg: NASDAQ)
# OUTPUT: List of quotes
# REFERENCE: http://ws.eoddata.com/data.asmx?op=Top10Losses
function top_10_losses(token::String, exchange::String)
	call = "/Top10Losses"
	args = ["Token"=>"$token", "Exchange"=>"$exchange"]
	xml_tree = get_response(call, args)

	# Set returned fields
 	message = lowercase(strip(find(xml_tree, "/RESPONSE[1]{Message}")))
	if message != "success"
		error("top_10_losses() failed with message returned of: $message")
	else
		# Shred xml_tree into a Dict{String, Quote}
		quotes = Dict{String, Quote}()
		for qt in find(xml_tree, "/RESPONSE/QUOTES/QUOTE")
			# Assign
			ticker_code::String = strip(get(qt.attr,"Symbol",""))
			description::String = strip(get(qt.attr,"Description",""))
			name::String = strip(get(qt.attr,"Name",""))
			date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime","")), DATETIMEFORMAT_SS)
			open::Float64 = float(strip(get(qt.attr,"Open","")))
			high::Float64 = float(strip(get(qt.attr,"High","")))
			low::Float64 = float(strip(get(qt.attr,"Low","")))
			close::Float64 = float(strip(get(qt.attr,"Close","")))
			volume::Float64 = float(strip(get(qt.attr,"Volume","")))
			open_interest::Float64 = float(strip(get(qt.attr,"OpenInterest","")))
			previous::Float64 = float(strip(get(qt.attr,"Previous","")))
			change::Float64 = float(strip(get(qt.attr,"Change","")))
			simple_return::Float64 = change / previous
			bid::Float64 = float(strip(get(qt.attr,"Bid","")))
			ask::Float64 = float(strip(get(qt.attr,"Ask","")))
			previous_close::Float64 = float(strip(get(qt.attr,"PreviousClose","")))
			next_open::Float64 = float(strip(get(qt.attr,"NextOpen","")))
			modified::DateTime = DateTime(strip(get(qt.attr,"Modified","")), DATETIMEFORMAT_MS)

			quotes[ticker_code] = Quote(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
										previous, change, simple_return, bid, ask, previous_close, next_open, modified)
		end
		return quotes
	end
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
