#=
    Unit tests for EodData external utility functions
=#
using Base.Test
using EodData
if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

dt = DateTime("20140101", "yyyymmdd")
d = Date("20140101", "yyyymmdd")

# set_date_string() with a ::DateTime
@test set_date_string(dt) == "20140101"
@test set_date_string(dt) != 20140101
@test set_date_string(dt) != dt
@test set_date_string(dt) != d
@test typeof(set_date_string(dt)) == typeof("20140101")

# set_date_string() with a ::Date
@test set_date_string(d) == "20140101"
@test set_date_string(d) != 20140101
@test set_date_string(d) != dt
@test set_date_string(d) != d
@test typeof(set_date_string(d)) == typeof("20140101")
