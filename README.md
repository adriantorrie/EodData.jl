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

resp = login(USERNAME, PASSWORD)
println(resp.message)
println(resp.token)

countries = country_list(resp.token)
println(countries)

version = data_client_latest_version(resp.token)
println(version)

formats = data_formats(resp.token)
println(formats)
```
