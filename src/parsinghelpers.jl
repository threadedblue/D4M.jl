# Functions that convert between r, c, v and r, c|v, 1 style Associative Arrays

# Default separator matches D4M.py convention ("|").
function col2type(A, splitSep = "|")
    # Inverse of val2col (see below for more info)
    r, c, v = find(A)
    cType, cVal = SplitStr(c, splitSep)
    return Assoc(r, Array{Union{AbstractString,Number}}(cType),
                    Array{Union{AbstractString,Number}}(cVal))
end

function val2col(A::Assoc, splitSep = "|")
    #val2col: Append associative array values to column keys; inverse of col2type.
    #Associative array user function.
    #  Usage:
    #    AA = val2col(A)          # separator defaults to "|"
    #    AA = val2col(A, splitSep)
    #  Inputs:
    #    A        = associative array with string column keys
    #    splitSep = single character separator (default "|")
    #  Outputs:
    #    AA = associative array with "col|val" column keys and numeric values

    r, cType, cVal = find(A)
    c = CatStr(cType, splitSep, cVal)
    return Assoc(r, c, 1)
end
