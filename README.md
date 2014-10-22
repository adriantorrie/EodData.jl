# EodData.jl
Julia package for connecting to EodData.com and downloading data.

* The source files are heavily documented, please review the source
for in-depth documentation, and references.
* The examples on this page can be found in `/examples/examples.jl`.

## Package Dependencies
* [EodData Web Service (Membership required)](http://ws.eoddata.com/data.asmx)
* [Dates.jl](https://github.com/JuliaLang/julia/tree/master/base/dates)
* [HTTPClient.jl](https://github.com/JuliaWeb/HTTPClient.jl)
* [LibExpat.jl](https://github.com/amitmurthy/LibExpat.jl)

## Usage
```
using EodData

const USERNAME = "string"
const PASSWORD = "string"
```

Call login. This will assign you a token which is needed to
make EodData web service calls
```
resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)
```

Call and assign countries
```
countries = country_list(resp.token)
println(countries)
```

Call and assign the latest version for EodData's data client
```
version = data_client_latest_version(resp.token)
println(version)
```

Call and assign the formats available, then assign the
Standard CSV format to work with at your leisure
```
formats = data_formats(resp.token)
println(formats)

csv = formats["CSV"]
println(csv.name)
println(csv.format_header)
for column=values(csv.columns)
	println("$(column.column_name) | $(column.column_header)")
end
```

Call and assign a single exchange, in this case the NASDAQ,
and assign to a variable to work with at your leisure
```
nasdaq = exchange_get(resp.token, "NASDAQ")
println(nasdaq.name)
println(nasdaq.advances)
println(nasdaq.declines)
println("Advance/Decline Ratio \= $(nasdaq.advances / nasdaq.declines)")
```

Call and assign the exchanges available (these can be iterated over
if you wish), then assign the New York Stock Exchange to work with
at your leisure
```
exchanges = exchange_list(resp.token)
println(exchanges)

nyse = exchanges["NYSE"]
println(nyse.name)
println(nyse.advances)
println(nyse.declines)
println("Advance/Decline Ratio \= $(nyse.advances / nyse.declines)")
```

Call and assign the number of months history available to download
for a given exchange.
```
months = exchange_months(resp.token,"NYSE")
println(months)
```

Call and assign the fundamentals of all the listings on a given exchange.
Here we look at the New Zealand Exchange (NZX) market capitalisation which
also has bonds listed on it, and from time-to-time options as well.
```
nzx_fundamentals = fundamental_list(resp.token,"NZX")

nzx_market_cap = 0.0
for listing = values(nzx_fundamentals)
	nzx_market_cap += listing.market_cap
end
println(nzx_market_cap)
@sprintf "%.2f" nzx_market_cap
```

Call and assign the response.
Not really necessary for end-users from what I can tell
```
resp = login_2(USERNAME,PASSWORD,"0.1")
```

Call and assign the users membership level/account type with EodData.com
```
membership = membership(resp.token)
println(membership)
```

Call and assign the end-of-day quote for a given instrument
Here we get the quote for JP Morgan
```
jpm = quote_get(resp.token, "NYSE", "JPM")
println(jpm)
println(jpm.close)
println(jpm.previous)
println(jpm.change)
println(jpm.simple_return)
```

Call and assign the end-of-day quotes for an exchange.
The collection can be iterated over if you wish
```
nyse_quotes = quote_list(resp.token, "NYSE")
```

Call and assign the end-of-day quotes for a custom group
The collection can be iterated over if you wish
```
my_quotes = quote_list_2(resp.token, "NYSE", "C,MS,JPM,BAC,DB")
println(my_quotes)
```
