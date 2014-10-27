#=
	EodData external utility functions
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
function set_date_string(dt)
	return string(year(dt)) * string(month(dt)) * string(day(dt))
end
