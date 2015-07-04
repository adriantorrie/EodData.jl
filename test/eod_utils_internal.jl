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

const MODULE_HOME = joinpath(homedir(), ".julia",  "v" * string(VERSION.major) * "." * string(VERSION.minor), "EodDataTestXml")
const TEST_HOME = joinpath("$MODULE_HOME", "xml")

# set_countries()
# ---------------
xml_tree_c_i_t = LibExpat.xp_parse(readall(joinpath("$TEST_HOME", "countries_invalid_token.xml")))
@test_throws ErrorException EodData.validate_xml(xml_tree_c_i_t)

xml_tree_c_s = LibExpat.xp_parse(readall(joinpath("$TEST_HOME", "countries_success.xml")))
@test EodData.validate_xml(xml_tree_c_s)

countries = EodData.set_countries(xml_tree_c_s)
@test length(countries) == 243

usa = countries["US"]
@test typeof(usa) == EodData.Country
@test usa.code == "US"
@test usa.name == "United States"

# set_data_formats()
# ------------------
xml_tree_df_i_t = LibExpat.xp_parse(readall(joinpath("$TEST_HOME", "data_formats_invalid_token.xml")))
@test_throws ErrorException EodData.validate_xml(xml_tree_df_i_t)

# xp_parse is failing to read the xml file
# xml_tree_df_s = xp_parse(readall(joinpath("$MODULE_HOME", "test", "xml", "data_formats_success.xml")))
# @test validate_xml(xml_tree_df_s)

# set_exchanges()
# --------------
xml_tree_el_i_t = LibExpat.xp_parse(readall(joinpath("$TEST_HOME", "exchange_list_invalid_token.xml")))
@test_throws ErrorException EodData.validate_xml(xml_tree_el_i_t)

xml_tree_el_s = LibExpat.xp_parse(readall(joinpath("$TEST_HOME", "exchange_list_success.xml")))
@test EodData.validate_xml(xml_tree_el_s)

exchanges = EodData.set_exchanges(xml_tree_el_s)
@test length(exchanges) == 33

nyse = exchanges["NYSE"]
@test typeof(nyse) == EodData.Exchange
@test nyse.code == "NYSE"
@test nyse.name == "New York Stock Exchange"
@test nyse.last_trade_date_time == DateTime("2014-10-31T16:59:57", "yyyy-mm-ddTHH:MM:SS")
@test nyse.country_code == "US"
@test nyse.currency_code == "USD"
@test_approx_eq nyse.advances 5100.0
@test_approx_eq nyse.declines 1880.0
@test nyse.suffix == ""
@test nyse.time_zone == "Eastern Standard Time"
@test nyse.is_intraday == true
@test nyse.intraday_start_date == DateTime("2008-01-01T00:00:00", "yyyy-mm-ddTHH:MM:SS")
@test nyse.has_intraday_product == true

# validate_http_response()
# build a response that succeeeds, and another that fails to for a @test_throws
response = HTTPC.post("http://requestb.in/api/v1/bins", "")
@test response.http_code == 200 ? EodData.validate_http_response(response) : true
