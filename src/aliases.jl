# Deprecated aliases: the pre-harmonization D4M.jl names.
# The new names follow D4M.py (see doc/d4m-name-map.md). Each old name forwards to
# the new one and warns once per call site when deprecation warnings are enabled.
# Remove only after every consumer has moved to the new names.

getrow(args...; kwargs...)    = (Base.depwarn("`getrow` is deprecated, use `get_row`.", :getrow);       get_row(args...; kwargs...))
getcol(args...; kwargs...)    = (Base.depwarn("`getcol` is deprecated, use `get_col`.", :getcol);       get_col(args...; kwargs...))
getval(args...; kwargs...)    = (Base.depwarn("`getval` is deprecated, use `get_val`.", :getval);       get_val(args...; kwargs...))
getadj(args...; kwargs...)    = (Base.depwarn("`getadj` is deprecated, use `get_adj`.", :getadj);       get_adj(args...; kwargs...))
sqIn(args...; kwargs...)      = (Base.depwarn("`sqIn` is deprecated, use `sqin`.", :sqIn);              sqin(args...; kwargs...))
sqOut(args...; kwargs...)     = (Base.depwarn("`sqOut` is deprecated, use `sqout`.", :sqOut);           sqout(args...; kwargs...))
CatKeyMul(args...; kwargs...) = (Base.depwarn("`CatKeyMul` is deprecated, use `catkeymul`.", :CatKeyMul); catkeymul(args...; kwargs...))
CatValMul(args...; kwargs...) = (Base.depwarn("`CatValMul` is deprecated, use `catvalmul`.", :CatValMul); catvalmul(args...; kwargs...))
col2type(args...; kwargs...)  = (Base.depwarn("`col2type` is deprecated, use `col_to_type`.", :col2type); col_to_type(args...; kwargs...))
ReadCSV(args...; kwargs...)   = (Base.depwarn("`ReadCSV` is deprecated, use `readcsv`.", :ReadCSV);     readcsv(args...; kwargs...))
WriteCSV(args...; kwargs...)  = (Base.depwarn("`WriteCSV` is deprecated, use `writecsv`.", :WriteCSV);  writecsv(args...; kwargs...))
printFull(args...; kwargs...) = (Base.depwarn("`printFull` is deprecated, use `printfull`.", :printFull); printfull(args...; kwargs...))
