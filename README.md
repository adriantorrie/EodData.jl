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

### login()
Call login. This will assign you a token which is needed to
make EodData web service calls
```
resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)
```

### country_list()
Call and assign countries
```
countries = country_list(resp.token)
println(countries)
```

### data_client_latest_version()
Call and assign the latest version for EodData's data client
```
version = data_client_latest_version(resp.token)
println(version)
```

### data_formats()
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

### exchange_get()
Call and assign a single exchange, in this case the NASDAQ,
and assign to a variable to work with at your leisure
```
nasdaq = exchange_get(resp.token, "NASDAQ")
println(nasdaq.name)
println(nasdaq.advances)
println(nasdaq.declines)
println("Advance/Decline Ratio \= $(nasdaq.advances / nasdaq.declines)")
```

### exchange_list()
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

### exchange_months()
Call and assign the number of months history available to download
for a given exchange.
```
months = exchange_months(resp.token,"NYSE")
println(months)
```

### fundamental_list()
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

### login_2()
Call and assign the response.
Not really necessary for end-users from what I can tell
```
resp = login_2(USERNAME,PASSWORD,"0.1")
```

### membership()
Call and assign the users membership level/account type with EodData.com
```
membership = membership(resp.token)
println(membership)
```

### quote_get()
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

### quote_list()
Call and assign the end-of-day quotes for an exchange.
The collection can be iterated over if you wish
```
nyse_quotes = quote_list(resp.token, "NYSE")
```

### quote_list_2()
Call and assign the end-of-day quotes for a custom group
The collection can be iterated over if you wish
```
my_quotes = quote_list_2(resp.token, "NYSE", "C,MS,JPM,BAC,DB")
println(my_quotes)
```

### quote_list_by_date()
Call and assign the end-of-day quotes for a custom date
The collection can be iterated over if you wish
```
nyse_20140605 = quote_list_by_date(resp.token, "NYSE", "20140605")

for qt = values(nyse_20140605)
	println("$(qt.name) | $(qt.close)")
end
```

### quote_list_by_date_period()
Call and assign quotes for a custom date, and a custom period
on a particular exchange. If you choose "h" this will return
hourly data for the exchange
The collection can be iterated over if you wish
```
cme_20141008_h = quote_list_by_date_period(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h)
	println(k)
end

for qt = values(cme_20141008_h)
	println("$(qt.symbol)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_array = collect(cme_20141008_h)
```

### quote_list_by_date_period_2()
Call and assign quotes, with a smaller type ::Quote_2, for a custom date, and a custom period
on a particular exchange. If you choose "h" this will return
hourly data for the exchange
The keys, values, and collection can be iterated over if you wish
```
cme_20141008_h_2 = quote_list_by_date_period_2(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h_2)
	println(k)
end

for qt = values(cme_20141008_h_2)
	println("$(qt.symbol)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_array = collect(cme_20141008_h_2)
```

### split_list_by_exchange()
Call and assign the most recent splits for a given exchange
```
nyse_splits = split_list_by_exchange(resp.token, "NYSE")
splits = collect(nyse_splits)
println(splits)
```

### split_list_by_symbol()
Call and assign the most recent splits for a given symbol on a particular exchange
```
nct_splits = split_list_by_symbol(resp.token, "NYSE", "NCT")
for sp = values(nct_splits)
	println("$(sp.symbol)\t|\tDate Time: $(sp.date_time)\t|\tRatio: $(sp.ratio)\t|\tPrice Multiplier: $(sp.price_multiplier)\t|\tReverse Split: $(sp.is_reverse_split)")
end
```

### symbol_changes_by_exchange()
Call and assign the most recent changes to stock symbols,
and changes to exchanges
```
amex_changes = symbol_changes_by_exchange(resp.token, "AMEX")
for sc = values(amex_changes)
	println(sc)
end
```

### symbol_chart()
Call and assign the url for a chart of the symbol's price history.
**Note:** There is no "safety" on this web service call, if you give it
incorrect exchanges, symbols, or incorrect combinations you will receive
no error.
url = symbol_chart(resp.token, "NYSE", "A")
println(url)
