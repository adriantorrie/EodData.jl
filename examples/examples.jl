using EodData

const USERNAME = "string"
const PASSWORD = "string"

# login()
# -------
# Call login. This will assign you a token which is needed to
# make EodData web service calls
resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)

# country_list()
# --------------
# Call and assign countries
countries = country_list(resp.token)
println(countries)

# data_client_latest_version()
# ----------------------------
# Call and assign the latest version for EodData's data client
version = data_client_latest_version(resp.token)
println(version)

# data_formats()
# --------------
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

# exchange_get()
# --------------
# Call and assign a single exchange, in this case the NASDAQ
# and assign the NASDAQ to a variable to work with at your leisure
nasdaq = exchange_get(resp.token, "NASDAQ")
println(nasdaq.name)
println(nasdaq.advances)
println(nasdaq.declines)
println("Advance/Decline Ratio \= $(nasdaq.advances / nasdaq.declines)")

# exchange_list()
# ---------------
# Call and assign the exchanges available (these can be iterated over
# if you wish), then assign the New York Stock Exchange to work with
# at your leisure
exchanges = exchange_list(resp.token)
println(exchanges)

nyse = exchanges["NYSE"]
println(nyse.name)
println(nyse.advances)
println(nyse.declines)
println("Advance/Decline Ratio \= $(nyse.advances / nyse.declines)")

# exchange_months()
# -----------------
# Call and assign the number of months history available to download
# for a given exchange.
months = exchange_months(resp.token,"NYSE")
println(months)

# fundamental_list()
# ------------------
# Call and assign the fundamentals of all the listings on a given exchange.
# Here we look at the New Zealand Exchange (NZX) market capitalisation which
# also has bonds listed on it, and from time-to-time options as well.
nzx_fundamentals = fundamental_list(resp.token,"NZX")

nzx_market_cap = 0.0
for listing = values(nzx_fundamentals)
	nzx_market_cap += listing.market_cap
end
println(nzx_market_cap)
@sprintf "%.2f" nzx_market_cap

# login_2()
# ---------
# Call and assign the response.
# Not really necessary for end-users from what I can tell
resp = login_2(USERNAME,PASSWORD,"0.1")

# membership()
# ------------
# Call and assign the users membership level/account type with EodData.com
membership = membership(resp.token)
println(membership)

# quote_get()
# -----------
# Call and assign the end-of-day quote for a given instrument
# Here we get the quote for JP Morgan
jpm = quote_get(resp.token, "NYSE", "JPM")
println(jpm)
println(jpm.close)
println(jpm.previous)
println(jpm.change)
println(jpm.simple_return)

# quote_list()
# ------------
# Call and assign the end-of-day quotes for an exchange.
# The collection can be iterated over if you wish
nyse_quotes = quote_list(resp.token, "NYSE")

# quote_list_2()
# --------------
# Call and assign the end-of-day quotes for a custom group
# on a particular exchange.
# The collection can be iterated over if you wish
my_quotes = quote_list_2(resp.token, "NYSE", "C,MS,JPM,BAC,DB")
println(my_quotes)

# quote_list_by_date()
# --------------------
# Call and assign the end-of-day quotes for a custom date
# on a particular exchange.
# The collection can be iterated over if you wish
nyse_20140605 = quote_list_by_date(resp.token, "NYSE", "20140605")
for qt = values(nyse_20140605)
	println("$(qt.name) | $(qt.close)")
end

# quote_list_by_date_2()
# ----------------------
# Call and assign end-of-day quotes, with a smaller type ::Quote_2
# for a custom date on a particular exchange.
# The collection can be iterated over if you wish
asx_20131203 = quote_list_by_date_2(resp.token, "ASX", "20131203")
for qt = values(asx_20131203)
	println("$(qt.ticker_code) | $(qt.close)")
end

# quote_list_by_date_period()
# ---------------------------
# Call and assign quotes for a custom date, and a custom period
# on a particular exchange. If you choose "h" this will return
# hourly data for the exchange
# The collection can be iterated over if you wish
cme_20141008_h = quote_list_by_date_period(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h)
	println(k)
end

for qt = values(cme_20141008_h)
	println("$(qt.ticker_code)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_h = collect(cme_20141008_h)

# quote_list_by_date_period_2()
# -----------------------------
# Call and assign quotes, with a smaller type ::Quote_2, for a custom date, and a custom period
# on a particular exchange. If you choose "h" this will return
# hourly data for the exchange
# The keys, values, and collection can be iterated over if you wish
cme_20141008_h_2 = quote_list_by_date_period_2(resp.token, "CME", "20141008", "h")

for k = keys(cme_20141008_h_2)
	println(k)
end

for qt = values(cme_20141008_h_2)
	println("$(qt.ticker_code)\t|\tDate Time: $(qt.date_time)\t|\tClose: $(qt.close)\t|\tVolume: $(qt.volume)")
end

cme_h_2 = collect(cme_20141008_h_2)

# split_list_by_exchange()
# ------------------------
# Call and assign the most recent splits for a given exchange
nyse_splits = split_list_by_exchange(resp.token, "NYSE")
splits = collect(nyse_splits)
println(splits)

# split_list_by_symbol()
# ----------------------
# Call and assign the most recent splits for a given symbol on a particular exchange
nct_splits = split_list_by_symbol(resp.token, "NYSE", "NCT")
for sp = values(nct_splits)
	println("$(sp.exchange_code)\t|\t$(sp.ticker_code)\t|\tDate Time: $(sp.date_time)\t|\tRatio: $(sp.ratio)\t|\tPrice Multiplier: $(sp.price_multiplier)\t|\tReverse Split: $(sp.is_reverse_split)")
end

# symbol_changes_by_exchange()
# ----------------------------
# Call and assign the most recent changes to stock symbols,
# and changes to exchanges
amex_changes = symbol_changes_by_exchange(resp.token, "AMEX")
for sc = values(amex_changes)
	println(sc)
end

# symbol_chart()
# --------------
# Call and assign the url for a chart of the symbol's
# price history.
# Note: There is no "safety" on this web service call, if you give it
# incorrect exchanges, symbols, or incorrect combinations you will receive
# no error.
url = symbol_chart(resp.token, "NYSE", "A")
println(url)

# symbol_get()
# ------------
# Call and assign the detail for a ticker
fb = symbol_get(resp.token, "NASDAQ", "FB")
println(fb)

# symbol_history()
# ----------------
# Call and assign quotes for a ticker from a start date until "today"
# Due to the web service not returning 100% data, the following fields of the quote type will
# be 0, or NaN:
# * open_interest
# * previous
# * change
# * simple_return
# * bid
# * ask
# * previous_close
# * next_open
# * modified
c_20140601_today = symbol_history(resp.token, "NYSE", "C", "20140601")
println(c_20140601_today)

# symbol_history_period()
# -----------------------
# Call and assign quotes for a ticker, for a date, and a custom period
# Due to the web service not returning 100% data, the following fields of the quote type will
# be 0, or NaN:
# * open_interest
# * previous
# * change
# * simple_return
# * bid
# * ask
# * previous_close
# * next_open
# * modified
pg_2014102_h = symbol_history_period(resp.token, "NYSE", "PG", "20141002", "h")
println(pg_2014102_h)

# symbol_history_period_by_date_range()
# -------------------------------------
# Call and assign quotes for a ticker, between a start date and end date, and a custom period
# Due to the web service not returning 100% data, the following fields of the quote type will
# be "", 0, or NaN:
# * description
# * name
# * open_interest
# * previous
# * change
# * simple_return
# * bid
# * ask
# * previous_close
# * next_open
# * modified
amzn_20141020_20141024_30 =
	symbol_history_period_by_date_range(resp.token, "NASDAQ", "AMZN", "20141020", "20141024", "30")
println(amzn_20141020_20141024_30)

# symbol_list()
# -------------
# Call and assign the tickers for a given exchange
nyse_tickers = symbol_list(resp.token, "NYSE")
println(nyse_tickers)

# symbol_list_2()
# ---------------
# Call and assign the tickers for a given exchange
# This is a "smaller" version of the ticker object with only the
# ticker code and ticker name
nyse_tickers_2 = symbol_list_2(resp.token, "NYSE")
println(nyse_tickers_2)

# technical_list()
# ----------------
# Call and assign the technical indicator values for each ticker on a given exchange
nyse_technicals = technical_list(resp.token, "NYSE")
println(nyse_technicals)

# top_10_gains()
# --------------
# Call and assign the quotes for the top 10 gains for the NZX,
# also collect the ticker codes into an array, as the ticker codes
# are the dictionary keys.
nzx_top_10_gains_dict = top_10_gains(resp.token, "NZX")
nzx_top_10_gains_tickers = collect(keys(nzx_top_10_gains_dict))
println(nzx_top_10_gains_tickers)

# top_10_losses()
# ---------------
# Call and assign the quotes for the top 10 losses for the NZX,
# also collect the ticker codes into an array, as the ticker codes
# are the dictionary keys.
nzx_top_10_losses_dict = top_10_losses(resp.token, "NZX")
nzx_top_10_losses_tickers = collect(keys(nzx_top_10_losses_dict))
println(nzx_top_10_losses_tickers)

# validate_access()
# -----------------
# The first call passes plain strings in.
# The second call uses a utility function `set_date_string()` to
# build a ::String argument based on today's date.
validate_access(resp.token, "NZX", "20141001", "h")
validate_access(resp.token, "NYSE", set_date_string(today()), "h")
