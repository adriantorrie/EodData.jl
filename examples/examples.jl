using EodData

const USERNAME = "string"
const PASSWORD = "string"


resp = login(USERNAME,PASSWORD)
println(resp.message)
println(resp.token)

countries = country_list(resp.token)
println(countries)
