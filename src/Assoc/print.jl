#import Base.print

#=
print : print Assoc in a way that mimics the Sparse Array print.
=#
function print(A::Assoc)
    if !isempty(A)
        r,c,v = find(A)
        [size(A)...; length.(A.col)]

        padR = max(ndigits(size(A)[1]), length.(A.row)...)
        padC = max(ndigits(size(A)[2]), length.(A.col)...)

        println.("  [", rpad.(r, padR), ", ", rpad.(c , padC), "]  =  ", v)
    else
        show(A)
    end
    return nothing
end

#=
printFull : print Assoc in tabular form.
=#
function printFull(A::Assoc)
    if !isempty(A)
        display(full(A))
    else
        show(A)
    end

    return nothing
end

#=
printTriple : return A in triple String form: (r,c) v 
=#
function printTriple(A::Assoc)

    if !isempty(A)
        r,c,v = find(A)
        println.("(" .* string.(r) .* "," .* string.(c) .* ")\t".* string.(v))
    else
        show(A)
    end

    return nothing
end

# ── DataFrame I/O ────────────────────────────────────────────────────────────

"""
    toTable(A::Assoc)

Convert an Associative Array to a Tables.jl-compatible table format (named tuple table).

This returns a vector of named tuples with columns: row, col, val.
The result is compatible with any Tables.jl consumer (DataFrame, CSV, etc.).

# Examples
```julia
julia> A = Assoc(["r1","r2"], ["c1","c2"], ["v1","v2"])
julia> table = toTable(A)
2-element Vector{NamedTuple}:
 (row="r1", col="c1", val="v1")
 (row="r2", col="c2", val="v2")
```
"""
function toTable(A::Assoc)
    if isempty(A)
        return NamedTuple{(:row, :col, :val)}[]
    end

    rowIndices, colIndices, vals = find(A)
    return [(row=string(r), col=string(c), val=string(v))
            for (r, c, v) in zip(rowIndices, colIndices, vals)]
end

"""
    toDataFrame(A::Assoc)

Convert an Associative Array to a DataFrame.

Requires the DataFrames package to be installed and loaded.
The resulting DataFrame has columns: row, col, val.

# Examples
```julia
julia> using D4M, DataFrames
julia> A = Assoc(["r1","r2"], ["c1","c2"], ["v1","v2"])
julia> df = toDataFrame(A)
2×3 DataFrame
 Row │ row     col     val
     │ String  String  String
─────┼───────────────────────
   1 │ r1      c1      v1
   2 │ r2      c2      v2
```
"""
function toDataFrame(A::Assoc)
    # Check if DataFrames is available
    if !isdefined(Main, :DataFrame)
        error(
            "DataFrames.jl is required for toDataFrame(). " *
            "Load it first: using DataFrames\n" *
            "Or use toTable() which returns a Tables.jl-compatible format."
        )
    end

    tableData = toTable(A)
    return Main.DataFrame(tableData)
end

"""
    printDataFrame(A::Assoc)

Print an Associative Array in DataFrame format.

This is a convenience function that displays the Assoc data as a formatted table.
If DataFrames.jl is available, uses DataFrame display; otherwise uses table format.

# Examples
```julia
julia> using D4M
julia> A = Assoc(["r1","r2"], ["c1","c2"], ["v1","v2"])
julia> printDataFrame(A)
```
"""
function printDataFrame(A::Assoc)
    if isempty(A)
        println("Empty Associative Array")
        return nothing
    end

    try
        if isdefined(Main, :DataFrame)
            df = toDataFrame(A)
            show(df)
        else
            # Fallback to table format
            tableData = toTable(A)
            for (i, row) in enumerate(tableData)
                println("[$i] row=$(row.row), col=$(row.col), val=$(row.val)")
            end
        end
    catch
        # Final fallback
        tableData = toTable(A)
        for (i, row) in enumerate(tableData)
            println("[$i] row=$(row.row), col=$(row.col), val=$(row.val)")
        end
    end

    return nothing
end

"""
    toTriplet(A::Assoc)

Convert Associative Array to triplet format (rows, cols, vals vectors).

Returns a named tuple of three vectors: rows, cols, vals.
Useful for constructing a DataFrame with custom column names.

# Examples
```julia
julia> using D4M, DataFrames
julia> A = Assoc(["r1","r2"], ["c1","c2"], ["v1","v2"])
julia> rows, cols, vals = toTriplet(A)

julia> df = DataFrame(
           rowKey=rows,
           colKey=cols,
           value=vals
       )
```
"""
function toTriplet(A::Assoc)
    if isempty(A)
        return (rows=String[], cols=String[], vals=String[])
    end

    rowIndices, colIndices, vals = find(A)
    return (
        rows=string.(rowIndices),
        cols=string.(colIndices),
        vals=string.(vals)
    )
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
#                    Lauren Milechin (lauren.milechin@mit.edu)
########################################################

