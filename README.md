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


## Web Service Calls
* [country_list()](./blob/master/README.md#country_list)
* [data_client_latest_version()](./blob/master/README.md#data_client_latest_version)
* [data_formats()](./blob/master/README.md#data_formats)
* [exchange_get()](./blob/master/README.md#exchange_get)
* [exchange_list()](./blob/master/README.md#exchange_list)
* [exchange_months()](./blob/master/README.md#exchange_months)
* [fundamental_list()](./blob/master/README.md#fundamental_list)
* [login()](./blob/master/README.md#login)
* [login_2()](./blob/master/README.md#login_2)
* [membership()](./blob/master/README.md#membership)
* [quote_get()](./blob/master/README.md#quote_get)
* [quote_list()](./blob/master/README.md#quote_list)
* [quote_list_2()](./blob/master/README.md#quote_list_2)
* [quote_list_by_date()](./blob/master/README.md#quote_list_by_date)
* [quote_list_by_date_2()](./blob/master/README.md#quote_list_by_date_2)
* [quote_list_by_date_period()](./blob/master/README.md#quote_list_by_date_period)
* [quote_list_by_date_period_2()](./blob/master/README.md#quote_list_by_date_period_2)
* [split_list_by_exchange()](./blob/master/README.md#split_list_by_exchange)
* [split_list_by_symbol()](./blob/master/README.md#split_list_by_symbol)
* [symbol_changes_by_exchange()](./blob/master/README.md#symbol_changes_by_exchange)
* [symbol_chart()](./blob/master/README.md#symbol_chart)
* [symbol_get()](./blob/master/README.md#symbol_get)
* [symbol_history()](./blob/master/README.md#symbol_history)
* [symbol_history_period()](./blob/master/README.md#symbol_history_period)
* [symbol_history_period_by_date_range()](./blob/master/README.md#symbol_history_period_by_date_range)
* [symbol_list()](./blob/master/README.md#symbol_list)
* [symbol_list_2()](./blob/master/README.md#symbol_list_2)
* [technical_list()](./blob/master/README.md#technical_list)
* [top_10_gains()](./blob/master/README.md#top_10_gains)
* [top_10_losses()](./blob/master/README.md#top_10_losses)
* update_data_format() ... **not implemented**
* [validate_access()](./blob/master/README.md#validate_access)


## Types
* [DataFormatColumn](./blob/master/README.md#dataformatcolumn)
* [DataFormat](./blob/master/README.md#dataformat)
* [Exchange](./blob/master/README.md#exchange)
* [Fundamental](./blob/master/README.md#fundamental)
* [LoginResponse](./blob/master/README.md#loginresponse)
* [Quote](./blob/master/README.md#quote)
* [Quote_2](./blob/master/README.md#quote_2)
* [Split](./blob/master/README.md#split)
* [TickerChange](./blob/master/README.md#tickerchange)
* [Ticker](./blob/master/README.md#ticker)
* [Ticker_2](./blob/master/README.md#ticker_2)
* [Technical](./blob/master/README.md#technical)

## Usage
```julia
using EodData

const USERNAME = "string"
const PASSWORD = "string"
```

### login()
Call login. This will assign you a token which is needed to
make EodData web service calls.
```Julia
resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)
```

### country_list()
Call and assign countries.
```
countries = country_list(resp.token)
println(countries)
```

### data_client_latest_version()
Call and assign the latest version for EodData's data client.
```
version = data_client_latest_version(resp.token)
println(version)
```

### data_formats()
Call and assign the formats available, then assign the
Standard CSV format to work with at your leisure.
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
and assign to a variable to work with at your leisure.
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
at your leisure.
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
Not really necessary for end-users from what I can tell.
```
resp = login_2(USERNAME,PASSWORD,"0.1")
```

### membership()
Call and assign the users membership level/account type with EodData.com.
```
membership = membership(resp.token)
println(membership)
```

### quote_get()
Call and assign the end-of-day quote for a given instrument.
Here we get the quote for JP Morgan.
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
The collection can be iterated over if you wish.
```
nyse_quotes = quote_list(resp.token, "NYSE")
```

### quote_list_2()
Call and assign the end-of-day quotes for a custom group.
The collection can be iterated over if you wish.
```
my_quotes = quote_list_2(resp.token, "NYSE", "C,MS,JPM,BAC,DB")
println(my_quotes)
```

### quote_list_by_date()
Call and assign the end-of-day quotes for a custom date.
The collection can be iterated over if you wish.
```
nyse_20140605 = quote_list_by_date(resp.token, "NYSE", "20140605")

for qt = values(nyse_20140605)
	println("$(qt.name) | $(qt.close)")
end
```

### quote_list_by_date_2
Call and assign end-of-day quotes, with a smaller type ::Quote_2
for a custom date on a particular exchange.
The collection can be iterated over if you wish.
```
asx_20131203 = quote_list_by_date_2(resp.token, "ASX", "20131203")
for qt = values(asx_20131203)
	println("$(qt.ticker_code) | $(qt.close)")
end
```

### quote_list_by_date_period()
Call and assign quotes for a custom date, and a custom period
on a particular exchange. If you choose "h" this will return
hourly data for the exchange.
The collection can be iterated over if you wish.
```
cme_20141008_h = quote_list_by_date_period(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h)
	println(k)
end

for qt = values(cme_20141008_h)
	println("$(qt.ticker_code)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_h = collect(cme_20141008_h)
```

### quote_list_by_date_period_2()
Call and assign quotes, with a smaller type ::Quote_2, for a custom date, and a custom period
on a particular exchange. If you choose "h" this will return
hourly data for the exchange.
The keys, values, and collection can be iterated over if you wish.
```
cme_20141008_h_2 = quote_list_by_date_period_2(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h_2)
	println(k)
end

for qt = values(cme_20141008_h_2)
	println("$(qt.ticker_code)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_h_2 = collect(cme_20141008_h_2)
```

### split_list_by_exchange()
Call and assign the most recent splits for a given exchange.
```
nyse_splits = split_list_by_exchange(resp.token, "NYSE")
splits = collect(nyse_splits)
println(splits)
```

### split_list_by_symbol()
Call and assign the most recent splits for a given symbol on a particular exchange.
```
nct_splits = split_list_by_symbol(resp.token, "NYSE", "NCT")
for sp = values(nct_splits)
	println("$(sp.exchange_code)\t|\t$(sp.ticker_code)\t|\tDate Time: $(sp.date_time)\t|\tRatio: $(sp.ratio)\t|\tPrice Multiplier: $(sp.price_multiplier)\t|\tReverse Split: $(sp.is_reverse_split)")
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
```
url = symbol_chart(resp.token, "NYSE", "A")
println(url)
```

### symbol_get()
Call and assign the detail for a ticker.
```
fb = symbol_get(resp.token, "NASDAQ", "FB")
println(fb)
```

### symbol_history()
Call and assign quotes for a ticker from a start date until "today".
Due to the web service not returning 100% data, the following fields of the ::Quote type will
be 0, or NaN:
* open_interest
* previous
* change
* simple_return
* bid
* ask
* previous_close
* next_open
* modified
```
c_20140601_today = symbol_history(resp.token, "NYSE", "C", "20140601")
println(c_20140601_today)
```

### symbol_history_period
Call and assign quotes for a ticker, for a date, and a custom period.
Due to the web service not returning 100% data, the following fields of the ::Quote type will
be 0, or NaN:
* open_interest
* previous
* change
* simple_return
* bid
* ask
* previous_close
* next_open
* modified
```
pg_2014102_h = symbol_history_period(resp.token, "NYSE", "PG", "20141002", "h")
println(pg_2014102_h)
```

### symbol_history_period_by_date_range()
Call and assign quotes for a ticker, between a start date and end date, and a custom period.
Due to the web service not returning 100% data, the following fields of the ::Quote type will
be "", 0, or NaN:
* description
* name
* open_interest
* previous
* change
* simple_return
* bid
* ask
* previous_close
* next_open
* modified
```
amzn_20141020_20141024_30 = symbol_history_period_by_date_range(resp.token, "NASDAQ", "AMZN", "20141020", "20141024", "30")
println(amzn_20141020_20141024_30)
```

### symbol_list()
Call and assign the tickers for a given exchange.
```
nyse_tickers = symbol_list(resp.token, "NYSE")
println(nyse_tickers)
```

### symbol_list_2()
Call and assign the tickers for a given exchange.
This is a "smaller" version of the ticker object with only the
ticker code and ticker name
```
nyse_tickers_2 = symbol_list_2(resp.token, "NYSE")
println(nyse_tickers_2)
```

### technical_list()
Call and assign the technical indicator values for each ticker on a given exchange.
```
nyse_technicals = technical_list(resp.token, "NYSE")
println(nyse_technicals)
```

### top_10_gains()
Call and assign the quotes for the top 10 gains for the NZX,
also collect the ticker codes into an array, as the ticker codes
are the dictionary keys.
```
nzx_top_10_gains_dict = top_10_gains(resp.token, "NZX")
nzx_top_10_gains_tickers = collect(keys(nzx_top_10_gains_dict))
println(nzx_top_10_gains_tickers)
```

### top_10_losses()
Call and assign the quotes for the top 10 losses for the NZX,
also collect the ticker codes into an array, as the ticker codes
are the dictionary keys.
```
nzx_top_10_losses_dict = top_10_losses(resp.token, "NZX")
nzx_top_10_losses_tickers = collect(keys(nzx_top_10_losses_dict))
println(nzx_top_10_losses_tickers)
```

### update_data_format()
This is not implemented.

## Data Types
### DataFormatColumn
```
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
```

### DataFormat
```
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
```

### Exchange
```
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
```

### Fundamental
```
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
```

### LoginResponse
```
type LoginResponse
	message::String
	token::String
end
```

### Quote
```
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
```

### Quote_2
```
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
```

### Split
```
type Split
	exchange_code::String
	ticker_code::String
	date_time::DateTime
	ratio::String
	price_multiplier::Float64
	share_float_multiplier::Float64
	is_reverse_split::Bool
end
```

### TickerChange
```
type TickerChange
	old_exchange_code::String
	new_exchange_code::String
	old_ticker_code::String
	new_ticker_code::String
	date_time::DateTime
	is_change_of_exchange_code::Bool
	is_change_of_ticker_code::Bool
end
```

### Ticker
```
type Ticker
	code::String
	name::String
	long_name::String
	date_time::DateTime
end
```

### Ticker_2
```
type Ticker_2
	code::String
	name::String
end
```

### Technical
```
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
```
