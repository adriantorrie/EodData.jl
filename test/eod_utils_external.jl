using EodData
using Dates
using Base.Test

dt = DateTime("20140101", "yyyymmdd")
d = Date("20140101", "yyyymmdd")

# set_date_string()
@test set_date_string(dt) == "20140101"
@test set_date_string(dt) != 20140101
@test set_date_string(dt) != dt
@test set_date_string(dt) != d

@test set_date_string(d) == "20140101"
@test set_date_string(d) != 20140101
@test set_date_string(d) != dt
@test set_date_string(d) != d
