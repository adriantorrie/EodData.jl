# EodData.jl
Julia package for connecting to eoddata.com and downloading data.

* The source files are heavily documented, please review the source for in-depth documentation.
* The examples on this page can be found in `/examples/examples.jl`

## Dependencies
* [Dates.jl](https://github.com/JuliaLang/julia/tree/master/base/dates)
* [HTTPClient.HTTPC](https://github.com/JuliaWeb/HTTPClient.jl)
* [LibExpat](https://github.com/amitmurthy/LibExpat.jl)

## Usage
```
using EodData

const USERNAME = "string"
const PASSWORD = "string"

# Call login. This will assign you a token which is needed to
# make EodData web service calls
resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)

# Call and assign countries
countries = country_list(resp.token)
println(countries)

# Call and assign the latest version for EodData's data client
version = data_client_latest_version(resp.token)
println(version)

# Call and assign the formats available, then assign the
# Standard CSV format to work with at your leisure
formats = data_formats(resp.token)
println(formats)

csv = formats["CSV"]
println(csv.name)
println(csv.format_header)
for column=values(csv.columns)
	println("$(column.column_name) | $(column.column_header)")
end

# Call and assign the exchanges available, then assign the
# New York Stock Exchange to work with at your leisure
exchanges = exchange_list(resp.token)
println(exchanges)

nyse = exchanges["NYSE"]
println(nyse.name)
println(nyse.advances)
println(nyse.declines)
println("Advance/Decline Ratio \= $(nyse.advances / nyse.declines)")
```
