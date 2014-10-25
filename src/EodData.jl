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
using Dates
using HTTPClient.HTTPC
using LibExpat

# ============================
# Make EodData types available
export DataFormat, DataFormatColumn, Exchange, Fundamental, LoginResponse, Quote, Quote_2,
		Split, TickerChange, Ticker

# =============
# EodData Types
type DataFormatColumn
	column_header::String
	sort_order::Int
	data_format_code::String
	data_format_name::String
	column_code::String
	column_name::String
	column_type_id::Int
	column_type::String
end

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
end

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
end

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
end

type LoginResponse
	message::String
	token::String
end

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
end

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
end

type Split
	exchange_code::String
	ticker_code::String
	date_time::DateTime
	ratio::String
	price_multiplier::Float64
	share_float_multiplier::Float64
	is_reverse_split::Bool
end

type TickerChange
	old_exchange_code::String
	new_exchange_code::String
	old_ticker_code::String
	new_ticker_code::String
	date_time::DateTime
	is_change_of_exchange_code::Bool
	is_change_of_ticker_code::Bool
end

type Ticker
	code::String
	name::String
	long_name::String
	date_time::DateTime
end

type Ticker_2
	code::String
	name::String
end

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
end

# =====
# Files
include("eod_utils_external.jl")
include("eod_utils_internal.jl")
include("eod_ws.jl")

end # module
