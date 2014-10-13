#=
	References
 	-----------

 		EODData now offers a complete end of day Web Service ideal for trading
		applications, web sites, portfolio management systems, etc.
		- http://eoddata.com/products/webservice.aspx
		- http://ws.eoddata.com/data.asmx

 		Package: HttpCommon
		- http://juliawebstack.org/#HttpCommon

		Package: LibExpat
		- https://github.com/amitmurthy/LibExpat.jl
		- http://nbviewer.ipython.org/github/amitmurthy/LibExpat.jl/blob/master/libexpat_test.ipynb
=#

module EodData

export CountryList

const WSDL::String = "http://ws.eoddata.com/data.asmx?wsdl"

type LoginResponse
	message::String
	token::String
end

function country_list(token)
	# Type code here
end

function data_client_latest_version()
	# Type code here
end

function data_formats()
	# Type code here
end

function exchange_get()
	# Type code here
end

function exchange_list()
	# Type code here
end

function exchange_months()
	# Type code here
end

function fundamental_list()
	# Type code here
end

function login()
	# Type code here
end

function membership()
	# Type code here
end

function quote_get()
	# Type code here
end

function quote_list()
	# Type code here
end

function quote_list_2()
	# Type code here
end

function quote_list_by_date()
	# Type code here
end

function quote_list_by_date_2()
	# Type code here
end

function quote_list_by_date_period()
	# Type code here
end

function quote_list_by_date_period_2()
	# Type code here
end

function split_list_by_exchange()
	# Type code here
end

function split_list_by_symbol()
	# Type code here
end

function symbol_changes_by_exchange()
	# Type code here
end

function symbol_chart()
	# Type code here
end

function symbol_get()
	# Type code here
end

function symbol_history()
	# Type code here
end

function symbol_history_period()
	# Type code here
end

function symbol_history_period_by_date_range()
	# Type code here
end

function symbol_list()
	# Type code here
end

function symbol_list_2()
	# Type code here
end

function technical_list()
	# Type code here
end

function top_10_gains()
	# Type code here
end

function top_10_losses()
	# Type code here
end

function update_data_format()
	# Type code here
end

function validate_access()
	# Type code here
end

include("aws_utils.jl")
include("crypto.jl")
include("EC2.jl")
include("S3.jl")

include("show.jl")

end # module
