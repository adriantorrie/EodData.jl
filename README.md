# EodData.jl
Julia package for connecting to eoddata.com and downloading data.

* The source files are heavily documented, please review the source for in-depth documentation.
* The examples on this page can be found in `/examples/examples.jl`

## Dependencies
* [HTTPClient.HTTPC](https://github.com/JuliaWeb/HTTPClient.jl)
* [LibExpat](https://github.com/amitmurthy/LibExpat.jl)

## Usage
```
using EodData

const USERNAME = "string"
const PASSWORD = "string"

login_response = login(USERNAME,PASSWORD)
println(login_response.message)
println(login_response.token)

countries = country_list(login_response.token)
println(countries)
```
