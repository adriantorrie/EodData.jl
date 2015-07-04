Pkg.clone("git://github.com/adriantorrie/EodDataTestXml.jl.git")
tests = ["eod_utils_external", "eod_utils_internal"]

for t in tests
    fpath = "$t.jl"
    @printf("running %s ...\n", fpath)
    include(fpath)
end
