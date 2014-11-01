module EodData
#=
	References
 	----------

	Julia language documentation
	- http://julia.readthedocs.org/en/latest/manual/
	- http://julia.readthedocs.org/en/latest/stdlib/base/
	- http://learnxinyminutes.com/docs/julia/
	- http://www.scolvin.com/juliabyexample/
	- http://perldoc.perl.org/perlre.html (regular expressions : regex)

	Hypertext Transfer Protocol
	- http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session

 	EODData now offers a complete end of day Web Service ideal for trading
	applications, web sites, portfolio management systems, etc.
	- http://ws.eoddata.com/data.asmx
	- http://ws.eoddata.com/data.asmx?wsdl
	- http://eoddata.com/products/webservice.aspx

 	Package: HTTPClient
	- https://github.com/JuliaWeb/HTTPClient.jl
	- https://github.com/JuliaWeb/HTTPClient.jl/blob/master/src/HTTPC.jl
	- https://github.com/JuliaWeb/HTTPClient.jl/blob/master/test/tests.jl

	Package: LibExpat
	- https://github.com/amitmurthy/LibExpat.jl
	- http://nbviewer.ipython.org/github/amitmurthy/LibExpat.jl/blob/master/libexpat_test.ipynb
=#
if VERSION < v"0.4-"
	using Dates
else
	using Base.Dates
end
using HTTPClient.HTTPC
using LibExpat

# ==================
# Internal constants
const DATETIMEFORMAT_SS = "yyyy-mm-ddTHH:MM:SS"
const DATETIMEFORMAT_MS = "yyyy-mm-ddTHH:MM:SS.ss"
const HEADER_DELIMITERS = [',', ';', ' ']

# ============================
# Make EodData types available
export DataFormat, DataFormatColumn, Exchange, Fundamental, LoginResponse,
		Quote, Quote_2, Split, TickerChange, Ticker

# =============
# EodData Types

# ::Country
type Country
	code::String
	name::String

	# Default constructor
	Country(code::String, name::String) = new(code, name)

	# Construct from XML ::ETree
	function Country(c::ETree)
		code::String = strip(get(c.attr,"Code",""))
		name::String = strip(get(c.attr,"Name",""))

		return new(code, name)
	end
end

# ::DataFormatColumn
type DataFormatColumn
	column_header::String
	sort_order::Int
	data_format_code::String
	data_format_name::String
	column_code::String
	column_name::String
	column_type_id::Int
	column_type::String

	# Default constructor
	DataFormatColumn(column_header::String, sort_order::Int, data_format_code::String,
					 data_format_name::String, column_code::String, column_name::String,
					 column_type_id::Int, column_type::String) =
		new(column_header, sort_order, data_format_code, data_format_name, column_code,
			column_name, column_type_id, column_type)

	# Construct from XML ::ETree
	function DataFormatColumn(col::ETree)
		column_header::String = strip(get(col.attr,"Header",""))
		sort_order::Int = int(strip(get(col.attr,"SortOrder","")))
		data_format_code::String = strip(get(col.attr,"Code",""))
		data_format_name::String = strip(get(col.attr,"DataFormat",""))
		column_code::String = strip(get(col.attr,"ColumnCode",""))
		column_name::String = strip(get(col.attr,"ColumnName",""))
		column_type_id::Int = int(strip(get(col.attr,"ColumnTypeId","")))
		column_type::String = strip(get(col.attr,"ColumnType",""))

		return new(column_header, sort_order, data_format_code, data_format_name, column_code,
				   column_name, column_type_id, column_type)
	end
end

# ::DataFormat
type DataFormat
	code::String
	name::String
	header_format::Vector{String}
	date_format::String
	extension::String
	include_suffix::Bool
	tab_column_seperator::Bool
	column_seperator::String
	text_qualifier::String
	filename_prefix::String
	filename_exchange_code::Bool
	filename_date::Bool
	include_header_row::Bool
	hour_format::String
	datetime_seperator::String
	exchange_filename_format_date::String
	exchange_filename_format_date_range::String
	ticker_filename_format_date::String
	ticker_filename_format_date_range::String
	columns::Dict{Int, DataFormatColumn}

	# Default constructor
	DataFormat(code::String, name::String, header_format::Vector{String}, date_format::String,
			   extension::String, include_suffix::Bool, tab_column_seperator::Bool,
			   column_seperator::String, text_qualifier::String, filename_prefix::String,
			   filename_exchange_code::String, filename_date::Bool, include_header_row::Bool,
			   hour_format::String, datetime_seperator::String, exchange_filename_format_date::String,
			   exchange_filename_format_date_range::String, ticker_filename_format_date::String,
			   ticker_filename_format_date_range::String, columns::Dict{Int, DataFormatColumn}) =
		new(code, name, header_format, date_format, extension, include_suffix, tab_column_seperator,
			column_seperator, text_qualifier, filename_prefix, filename_exchange_code, filename_date,
			include_header_row, hour_format, datetime_seperator, exchange_filename_format_date,
			exchange_filename_format_date_range, ticker_filename_format_date,
			ticker_filename_format_date_range, columns)

	# Construct from XML ::ETree
	function DataFormat(df::ETree)
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

		columns = Dict{Int, DataFormatColumn}()
		for col_xml in find(df, "COLUMNS/DATAFORMAT_COLUMN")
			columns[col.sort_order] = col = DataFormatColumn(col_xml)
		end

		return new(code, name, header_format, date_format, extension, include_suffix, tab_column_seperator,
				   column_seperator, text_qualifier, filename_prefix, filename_exchange_code, filename_date,
				   include_header_row, hour_format, datetime_seperator, exchange_filename_format_date,
				   exchange_filename_format_date_range, ticker_filename_format_date,
				   ticker_filename_format_date_range, columns)
	end
end

# ::Exchange
type Exchange
	code::String
	name::String
	last_trade_date_time::DateTime
	country_code::String
	currency_code::String
	advances::Float64
	declines::Float64
	suffix::String
	time_zone::String
	is_intraday::Bool
	intraday_start_date::DateTime
	has_intraday_product::Bool

	# Default constructor
	Exchange(code::String, name::String, last_trade_date_time::DateTime, country_code::String,
			 currency_code::String, advances::Float64, declines::Float64,suffix::String,
			 time_zone::String, is_intraday::Bool, intraday_start_date::DateTime,
			 has_intraday_product::Bool) =
		new(code, name, last_trade_date_time, country_code, currency_code, advances, declines,
			suffix, time_zone, is_intraday, intraday_start_date, has_intraday_product)

	# Construct from XML ::ETree
	function Exchange(ex::ETree)
		code::String = strip(get(ex.attr,"Code",""))
		name::String = strip(get(ex.attr,"Name",""))
		last_trade_date_time::DateTime  = DateTime(strip(get(ex.attr,"LastTradeDateTime",""))[1:19], DATETIMEFORMAT_SS)
		country_code::String = strip(get(ex.attr,"Country",""))
		currency_code::String = strip(get(ex.attr,"Currency",""))
		advances::Float64 = float(strip(get(ex.attr,"Advances","")))
		declines::Float64 = float(strip(get(ex.attr,"Declines","")))
		suffix::String = strip(get(ex.attr,"Suffix",""))
		time_zone::String = strip(get(ex.attr,"TimeZone",""))
		is_intraday::Bool = lowercase(strip(get(ex.attr,"IsIntraday",""))) == "true" ? true : false
		intraday_start_date::DateTime = DateTime(strip(get(ex.attr,"IntradayStartDate",""))[1:19], DATETIMEFORMAT_SS)
		has_intraday_product::Bool = lowercase(strip(get(ex.attr,"HasIntradayProduct",""))) == "true" ? true : false

		return new(code, name, last_trade_date_time, country_code, currency_code, advances,
				   declines,suffix, time_zone, is_intraday, intraday_start_date, has_intraday_product)
	end
end

# ::Fundamental
type Fundamental
	ticker_code::String
	name::String
	description::String
	date_time::DateTime
	industry::String
	sector::String
	share_float::Float64
	market_cap::Float64
	pe_ratio::Float64
	earnings_per_share::Float64
	net_tangible_assets::Float64
	dividend_yield::Float64
	dividend::Float64
	dividend_date::DateTime
	dividend_per_share::Float64
	imputation_credits::Float64
	ebitda::Float64
	peg_ratio::Float64
	ps_ratio::Float64
	pb_ratio::Float64
	yield::Float64

	# Default constructor
	Fundamental(ticker_code::String, name::String, description::String, date_time::DateTime,
				industry::String, sector::String, share_float::Float64, market_cap::Float64,
				pe_ratio::Float64, earnings_per_share::Float64, net_tangible_assets::Float64,
				dividend_yield::Float64, dividend::Float64, dividend_date::DateTime,
				dividend_per_share::Float64, imputation_credits::Float64, ebitda::Float64,
				peg_ratio::Float64, ps_ratio::Float64, pb_ratio::Float64, yield::Float64) =
		new(ticker_code, name, description, date_time, industry, sector, share_float,
			market_cap, pe_ratio, earnings_per_share, net_tangible_assets, dividend_yield,
			dividend, dividend_date, dividend_per_share, imputation_credits, ebitda,
			peg_ratio, ps_ratio, pb_ratio, yield)

	# Construct from XML ::ETree
	function Fundamental(fl::ETree)
		ticker_code::String = strip(get(fl.attr,"Symbol",""))
		name::String = strip(get(fl.attr,"Name",""))
		description::String = strip(get(fl.attr,"Description",""))
		date_time::DateTime = DateTime(strip(get(fl.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)
		industry::String = strip(get(fl.attr,"Industry",""))
		sector::String = strip(get(fl.attr,"Sector",""))
		share_float::Float64 = float(strip(get(fl.attr,"Shares","")))
		market_cap::Float64 = float(strip(get(fl.attr,"MarketCap","")))
		pe_ratio::Float64 = float(strip(get(fl.attr,"PE","")))
		earnings_per_share::Float64 = float(strip(get(fl.attr,"EPS","")))
		net_tangible_assets::Float64 = float(strip(get(fl.attr,"NTA","")))
		dividend_yield::Float64 = float(strip(get(fl.attr,"DivYield","")))
		dividend::Float64 = float(strip(get(fl.attr,"Dividend","")))
		dividend_date::DateTime = DateTime(strip(get(fl.attr,"DividendDate",""))[1:19], DATETIMEFORMAT_SS)
		dividend_per_share::Float64 = float(strip(get(fl.attr,"DPS","")))
		imputation_credits::Float64 = float(strip(get(fl.attr,"ImputationCredits","")))
		ebitda::Float64 = float(strip(get(fl.attr,"EBITDA","")))
		peg_ratio::Float64 = float(strip(get(fl.attr,"PEG","")))
		ps_ratio::Float64 = float(strip(get(fl.attr,"PtS","")))
		pb_ratio::Float64 = float(strip(get(fl.attr,"PtB","")))
		yield::Float64 = float(strip(get(fl.attr,"Yield","")))

		return new(ticker_code, name, description, date_time, industry, sector, share_float,
				   market_cap, pe_ratio, earnings_per_share, net_tangible_assets, dividend_yield,
				   dividend, dividend_date, dividend_per_share, imputation_credits, ebitda,
				   peg_ratio, ps_ratio, pb_ratio, yield)
	end
end

# ::LoginResponse
type LoginResponse
	message::String
	token::String

	# Default constructor
	LoginResponse(message::String, token::String) = new(message, token)

	# Construct from XML ::ETree
	function LoginResponse(lr::ETree)
		message = strip(find(lr, "/LOGINRESPONSE[1]{Message}"))
		token = strip(find(lr, "/LOGINRESPONSE[1]{Token}"))

		return new(message, token)
	end
end

# ::Quote
type Quote
	ticker_code::String
	description::String
	name::String
	date_time::DateTime
	open::Float64
	high::Float64
	low::Float64
	close::Float64
	volume::Float64
	open_interest::Float64
	previous::Float64
	change::Float64
	simple_return::Float64
	bid::Float64
	ask::Float64
	previous_close::Float64
	next_open::Float64
	modified::DateTime

	# Default constructor
	Quote(ticker_code::String, description::String, name::String, date_time::DateTime, open::Float64,
		  high::Float64, low::Float64, close::Float64, volume::Float64, open_interest::Float64,
		  previous::Float64, change::Float64, simple_return::Float64, bid::Float64, ask::Float64,
		  previous_close::Float64, next_open::Float64, modified::DateTime) =
		new(ticker_code, description, name, date_time, open, high, low, close, volume, open_interest,
				   previous, change, simple_return, bid, ask, previous_close, next_open, modified)

	# Construct from XML ::ETree
	function Quote(qt::ETree)
		ticker_code::String = strip(get(qt.attr,"Symbol",""))
		description::String = strip(get(qt.attr,"Description",""))
		name::String = strip(get(qt.attr,"Name",""))
		date_time::DateTime = DateTime(strip(get(qt.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)
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
		modified::DateTime = DateTime(strip(get(qt.attr,"Modified",""))[1:19], DATETIMEFORMAT_SS)

		return new(ticker_code, description, name, date_time, open, high, low, close, volume,
				   open_interest, previous, change, simple_return, bid, ask, previous_close,
				   next_open, modified)
	end
end

# ::Quote_2
type Quote_2
	ticker_code::String
	date_time::DateTime
	open::Float64
	high::Float64
	low::Float64
	close::Float64
	volume::Float64
	open_interest::Float64
	bid::Float64
	ask::Float64

	# Default constructor
	Quote_2(ticker_code::String, date_time::DateTime, open::Float64, high::Float64, low::Float64,
			close::Float64, volume::Float64, open_interest::Float64, bid::Float64, ask::Float64) =
		new(ticker_code, date_time, open, high, low, close, volume, open_interest, bid, ask)

	# Construct from XML ::ETree
	function Quote_2(qt_2::ETree)
		ticker_code::String = strip(get(qt_2.attr,"s",""))
		date_time::DateTime = DateTime(strip(get(qt_2.attr,"d",""))[1:19], DATETIMEFORMAT_SS)
		open::Float64 = float(strip(get(qt_2.attr,"o","")))
		high::Float64 = float(strip(get(qt_2.attr,"h","")))
		low::Float64 = float(strip(get(qt_2.attr,"l","")))
		close::Float64 = float(strip(get(qt_2.attr,"c","")))
		volume::Float64 = float(strip(get(qt_2.attr,"v","")))
		open_interest::Float64 = float(strip(get(qt_2.attr,"i","")))
		bid::Float64 = float(strip(get(qt_2.attr,"b","")))
		ask::Float64 = float(strip(get(qt_2.attr,"a","")))

		return new(ticker_code, date_time, open, high, low, close, volume, open_interest, bid, ask)
	end
end

# ::Split
type Split
	exchange_code::String
	ticker_code::String
	date_time::DateTime
	ratio::String
	price_multiplier::Float64
	share_float_multiplier::Float64
	is_reverse_split::Bool

	# Default constructor
	Split(exchange_code::String, ticker_code::String, date_time::DateTime, ratio::String,
		  price_multiplier::Float64, share_float_multiplier::Float64, is_reverse_split::Bool) =
		new(exchange_code, ticker_code, date_time, ratio, price_multiplier,
			share_float_multiplier, is_reverse_split)

	# Construct from XML ::ETree
	function Split(sp::ETree)
		exchange_code::String = strip(get(sp.attr,"Exchange",""))
		ticker_code::String = strip(get(sp.attr,"Symbol",""))
		date_time::DateTime = DateTime(strip(get(sp.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)
		ratio::String = strip(get(sp.attr,"Ratio",""))
		price_multiplier::Float64 = float(strip(split(ratio, "-")[2])) / float(strip(split(ratio, "-")[1]))
		share_float_multiplier::Float64 = float(strip(split(ratio, "-")[1])) / float(strip(split(ratio, "-")[2]))
		is_reverse_split::Bool = price_multiplier > 1.0 ? true : false

		new(exchange_code, ticker_code, date_time, ratio, price_multiplier,
			share_float_multiplier, is_reverse_split)
	end
end

# ::Technical
type Technical
	ticker_code::String
	name::String
	description::String
	date_time::DateTime
	previous::Float64
	change::Float64
	ma_1::Float64
	ma_2::Float64
	ma_5::Float64
	ma_20::Float64
	ma_50::Float64
	ma_100::Float64
	ma_200::Float64
	ma_percent::Float64
	ma_return::Float64
	volume_change::Float64
	three_month_change::Float64
	six_month_change::Float64
	week_high::Float64
	week_low::Float64
	week_change::Float64
	avg_week_change::Float64
	avg_week_volume::Float64
	week_volume::Float64
	month_high::Float64
	month_low::Float64
	month_change::Float64
	avg_month_change::Float64
	avg_month_volume::Float64
	month_volume::Float64
	year_high::Float64
	year_low::Float64
	year_change::Float64
	avg_year_change::Float64
	avg_year_volume::Float64
	ytd_change::Float64
	rsi_14::Float64
	sto_9::Float64
	wpr_14::Float64
	mtm_14::Float64
	roc_14::Float64
	ptc::Float64
	sar::Float64
	volatility::Float64
	liquidity::Float64

	# Default constructor
	Technical(ticker_code::String, name::String, description::String, date_time::DateTime,
			  previous::Float64, change::Float64, ma_1::Float64, ma_2::Float64, ma_5::Float64,
			  ma_20::Float64, ma_50::Float64, ma_100::Float64, ma_200::Float64, ma_percent::Float64,
			  ma_return::Float64, volume_change::Float64, three_month_change::Float64,
			  six_month_change::Float64, week_high::Float64, week_low::Float64, week_change::Float64,
			  avg_week_change::Float64, avg_week_volume::Float64, week_volume::Float64,
			  month_high::Float64, month_low::Float64, month_change::Float64, avg_month_change::Float64,
			  avg_month_volume::Float64, month_volume::Float64, year_high::Float64, year_low::Float64,
			  year_change::Float64, avg_year_change::Float64, avg_year_volume::Float64,
			  ytd_change::Float64, rsi_14::Float64, sto_9::Float64, wpr_14::Float64, mtm_14::Float64,
			  roc_14::Float64, ptc::Float64, sar::Float64, volatility::Float64, liquidity::Float64) =
		new(ticker_code, name, description, date_time, previous, change, ma_1, ma_2, ma_5,
			ma_20, ma_50, ma_100, ma_200, ma_percent, ma_return, volume_change,
			three_month_change, six_month_change, week_high, week_low, week_change,
			avg_week_change, avg_week_volume, week_volume, month_high, month_low,
			month_change, avg_month_change, avg_month_volume, month_volume, year_high,
			year_low, year_change, avg_year_change, avg_year_volume, ytd_change, rsi_14,
			sto_9, wpr_14, mtm_14, roc_14, ptc, sar, volatility, liquidity)

	# Construct from XML ::ETree
	function Technical(tl::ETree)
		ticker_code::String = strip(get(tl.attr,"Symbol",""))
		name::String = strip(get(tl.attr,"Name",""))
		description::String = strip(get(tl.attr,"Description",""))
		date_time::DateTime = DateTime(strip(get(tl.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)
		previous::Float64 = float(strip(get(tl.attr,"Previous","")))
		change::Float64 = float(strip(get(tl.attr,"Change","")))
		ma_1::Float64 = float(strip(get(tl.attr,"MA1","")))
		ma_2::Float64 = float(strip(get(tl.attr,"MA2","")))
		ma_5::Float64 = float(strip(get(tl.attr,"MA5","")))
		ma_20::Float64 = float(strip(get(tl.attr,"MA20","")))
		ma_50::Float64 = float(strip(get(tl.attr,"MA50","")))
		ma_100::Float64 = float(strip(get(tl.attr,"MA100","")))
		ma_200::Float64 = float(strip(get(tl.attr,"MA200","")))
		ma_percent::Float64 = float(strip(get(tl.attr,"MAPercent","")))
		ma_return::Float64 = float(strip(get(tl.attr,"MAReturn","")))
		volume_change::Float64 = float(strip(get(tl.attr,"VolumeChange","")))
		three_month_change::Float64 = float(strip(get(tl.attr,"ThreeMonthChange","")))
		six_month_change::Float64 = float(strip(get(tl.attr,"SixMonthChange","")))
		week_high::Float64 = float(strip(get(tl.attr,"WeekHigh","")))
		week_low::Float64 = float(strip(get(tl.attr,"WeekLow","")))
		week_change::Float64 = float(strip(get(tl.attr,"WeekChange","")))
		avg_week_change::Float64 = float(strip(get(tl.attr,"AvgWeekChange","")))
		avg_week_volume::Float64 = float(strip(get(tl.attr,"AvgWeekVolume","")))
		week_volume::Float64 = float(strip(get(tl.attr,"WeekVolume","")))
		month_high::Float64 = float(strip(get(tl.attr,"MonthHigh","")))
		month_low::Float64 = float(strip(get(tl.attr,"MonthLow","")))
		month_change::Float64 = float(strip(get(tl.attr,"MonthChange","")))
		avg_month_change::Float64 = float(strip(get(tl.attr,"AvgMonthChange","")))
		avg_month_volume::Float64 = float(strip(get(tl.attr,"AvgMonthVolume","")))
		month_volume::Float64 = float(strip(get(tl.attr,"MonthVolume","")))
		year_high::Float64 = float(strip(get(tl.attr,"YearHigh","")))
		year_low::Float64 = float(strip(get(tl.attr,"YearLow","")))
		year_change::Float64 = float(strip(get(tl.attr,"YearChange","")))
		avg_year_change::Float64 = float(strip(get(tl.attr,"AvgYearChange","")))
		avg_year_volume::Float64 = float(strip(get(tl.attr,"AvgYearVolume","")))
		ytd_change::Float64 = float(strip(get(tl.attr,"YTDChange","")))
		rsi_14::Float64 = float(strip(get(tl.attr,"RSI14","")))
		sto_9::Float64 = float(strip(get(tl.attr,"STO9","")))
		wpr_14::Float64 = float(strip(get(tl.attr,"WPR14","")))
		mtm_14::Float64 = float(strip(get(tl.attr,"MTM14","")))
		roc_14::Float64 = float(strip(get(tl.attr,"ROC14","")))
		ptc::Float64 = float(strip(get(tl.attr,"PTC","")))
		sar::Float64 = float(strip(get(tl.attr,"SAR","")))
		volatility::Float64 = float(strip(get(tl.attr,"Volatility","")))
		liquidity::Float64 = float(strip(get(tl.attr,"Liquidity","")))

		return new(ticker_code, name, description, date_time, previous, change, ma_1, ma_2,
				   ma_5, ma_20, ma_50, ma_100, ma_200, ma_percent, ma_return, volume_change,
				   three_month_change, six_month_change, week_high, week_low, week_change,
				   avg_week_change, avg_week_volume, week_volume, month_high, month_low,
				   month_change, avg_month_change, avg_month_volume, month_volume, year_high,
				   year_low, year_change, avg_year_change, avg_year_volume, ytd_change,
				   rsi_14, sto_9, wpr_14, mtm_14, roc_14, ptc, sar, volatility, liquidity)
	end
end

# ::Ticker
type Ticker
	code::String
	name::String
	long_name::String
	date_time::DateTime

	# Default constructor
	Ticker(code::String, name::String, long_name::String, date_time::DateTime) =
		new(code, name, long_name, date_time)

	# Construct from XML ::ETree
	function Ticker(tk::ETree)
		code::String = strip(get(tk.attr,"Code",""))
		name::String = strip(get(tk.attr,"Name",""))
		long_name::String = strip(get(tk.attr,"LongName",""))
		date_time::DateTime = DateTime(strip(get(tk.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)

		return new(code, name, long_name, date_time)
	end
end

# ::Ticker_2
type Ticker_2
	code::String
	name::String

	# Default constructor
	Ticker_2(code::String, name::String) = new(code, name)

	# Construct from XML ::ETree
	function Ticker_2(tk_2::ETree)
		code::String = strip(get(tk_2.attr,"Code",""))
		name::String = strip(get(tk_2.attr,"Name",""))

		return new(code, name)
	end
end

# ::TickerChange
type TickerChange
	old_exchange_code::String
	new_exchange_code::String
	old_ticker_code::String
	new_ticker_code::String
	date_time::DateTime
	is_change_of_exchange_code::Bool
	is_change_of_ticker_code::Bool

	# Default constructor
	TickerChange(old_exchange_code::String, new_exchange_code::String, old_ticker_code::String,
				 new_ticker_code::String, date_time::DateTime, is_change_of_exchange_code::Bool,
				 is_change_of_ticker_code::Bool) =
		new(old_exchange_code, new_exchange_code, old_ticker_code, new_ticker_code, date_time,
			is_change_of_exchange_code, is_change_of_ticker_code)

	# Construct from XML ::ETree
	function TickerChange(tc::ETree)
		old_exchange_code::String = strip(get(tc.attr,"ExchangeCode",""))
		new_exchange_code::String = strip(get(tc.attr,"NewExchangeCode",""))
		old_ticker_code::String = strip(get(tc.attr,"OldSymbol",""))
		new_ticker_code::String = strip(get(tc.attr,"NewSymbol",""))
		date_time::DateTime = DateTime(strip(get(tc.attr,"DateTime",""))[1:19], DATETIMEFORMAT_SS)
		is_change_of_exchange_code::Bool = old_exchange_code != new_exchange_code ? true : false
		is_change_of_ticker_code::Bool = old_ticker_code != new_ticker_code ? true : false

		return	new(old_exchange_code, new_exchange_code, old_ticker_code, new_ticker_code,
					date_time, is_change_of_exchange_code, is_change_of_ticker_code)
	end
end


# =====
# Files
include("eod_utils_external.jl")
include("eod_utils_internal.jl")
include("eod_ws.jl")

end # module
