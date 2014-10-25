#=
	EodData internal module functions
=#
export set_date_string

# =========
# Functions

# set_date_string()
# -----------------
# Returns a string that represents a date
# INPUT: Date data type
# OUTPUT: Xml tree of the type ::ETree
# http://ws.eoddata.com/data.asmx?op=CountryList
function set_date_string(date)
	return string(year(date)) * string(month(date)) * string(day(date))
end
