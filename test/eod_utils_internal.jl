#=
	Unit tests for EodData internal utility functions
=#
using Base.Test
if VERSION < v"0.4-"
	using Dates
else
	using Base.Dates
end
using EodData
using HTTPClient.HTTPC
using LibExpat

include("../src/eod_utils_internal.jl")

response = HTTPC.post("http://requestb.in/api/v1/bins", "")
validate_http_response(response)


# set_date_string()
@test response.http_code == 200 ? validate_http_response(response) : true
