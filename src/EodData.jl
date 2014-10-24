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
		Split, SymbolChange

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
	symbol_filename_format_date::String
	symbol_filename_format_date_range::String
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
	symbol::String
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
	symbol::String
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
	symbol::String
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
	symbol::String
	date_time::DateTime
	ratio::String
	price_multiplier::Float64
	share_float_multiplier::Float64
	is_reverse_split::Bool
end

type SymbolChange
	old_exchange_code::String
	new_exchange_code::String
	old_symbol::String
	new_symbol::String
	date_time::DateTime
	is_change_of_exchange_code::Bool
	is_change_of_symbol_code::Bool
end

# =====
# Files
include("eod_utils.jl")
include("eod_ws.jl")

end # module
