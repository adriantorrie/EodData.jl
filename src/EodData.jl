module EodData
#=
	References
 	----------

	Julia language documentation
	- http://julia.readthedocs.org/en/latest/manual/
	- http://julia.readthedocs.org/en/latest/stdlib/base/
	- http://learnxinyminutes.com/docs/julia/
	- http://www.scolvin.com/juliabyexample/

	Hypertext Transfer Protocol
	- http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session

 	EODData now offers a complete end of day Web Service ideal for trading
	applications, web sites, portfolio management systems, etc.
	- http://eoddata.com/products/webservice.aspx
	- http://ws.eoddata.com/data.asmx
	- http://ws.eoddata.com/data.asmx?wsdl

 	Package: HTTPClient
	- https://github.com/JuliaWeb/HTTPClient.jl
	- https://github.com/JuliaWeb/HTTPClient.jl/blob/master/src/HTTPC.jl
	- https://github.com/JuliaWeb/HTTPClient.jl/blob/master/test/tests.jl

	Package: LibExpat
	- https://github.com/amitmurthy/LibExpat.jl
	- http://nbviewer.ipython.org/github/amitmurthy/LibExpat.jl/blob/master/libexpat_test.ipynb
=#
using HTTPClient.HTTPC
using LibExpat

# ============================
# Make EodData types available
export DataFormat, DataFormatColumn, LoginResponse

# =============
# EodData Types
type DataFormatColumn
	column_header::String
	sort_order::Int32
	data_format_code::String
	data_format_name::String
	column_code::String
	column_name::String
	column_type_id::Int32
	column_type::String
end

type DataFormat
	code::String
	name::String
	format_header::Vector{String}
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
	columns::Dict{Int32, DataFormatColumn}
end

type LoginResponse
	message::String
	token::String
end

# =====
# Files
include("eod_utils.jl")
include("eod_ws.jl")

end # module
