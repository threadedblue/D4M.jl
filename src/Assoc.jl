
#Allow sorting between Numbers and Strings
isless(A::Number, B::AbstractString) = false
isless(A::AbstractString, B::Number) = true

# StringOrNumArray: broad union used in factory constructor signatures.
const StringOrNumArray = Union{AbstractString,Array,Number}

#=
Assoc{K,V} — Associative Array, parameterized on key type K and value type V.

K = key element type, shared by row and col (typically String; Int for numeric keys).
V = value element type (String for string-valued Assoc; Float64 for numeric Assoc).

For numeric Assoc, val == [1.0] is the sentinel: actual values live in A.nzval.
For string Assoc, val holds the unique sorted value dictionary; A.nzval holds indices.
=#
struct Assoc{K,V}
    row::Vector{K}
    col::Vector{K}
    val::Vector{V}
    A::SparseMatrixCSC

    function Assoc{K,V}(row::Vector{K}, col::Vector{K}, val::Vector{V},
                        A::SparseMatrixCSC) where {K,V}
        new{K,V}(row, col, val, A)
    end
end

#=
Concrete outer constructor: used by internal callers that already hold typed vectors
(slices of A.row / A.col / A.val are automatically the right Vector{K} or Vector{V}).
This is zero-overhead — no conversion, just structural assembly.
=#
Assoc(row::Vector{K}, col::Vector{K}, val::Vector{V},
      A::SparseMatrixCSC) where {K,V} = Assoc{K,V}(row, col, val, A)

#=
Fallback outer constructor: accepts AbstractVector for backward-compatible callers
(legacy Array{Union{AbstractString,Number}} arrays, promote()-based results from
sum/norow/nocol). Applies the numeric-sentinel normalization the old inner constructor
provided (raw numeric val → [1.0] sentinel).
=#
function Assoc(row::AbstractVector, col::AbstractVector, val::AbstractVector,
               A::SparseMatrixCSC)
    if !isempty(val) && isa(val[1], Number)
        val = Float64[1.0]
    end
    Kr = isempty(row) ? String : eltype(row)
    Kc = isempty(col) ? String : eltype(col)
    Kt = Union{Kr,Kc}   # Julia normalizes Union{T,T} → T for the common case
    Vt = (isempty(val) || isa(val[1], Number)) ? Float64 : String
    Assoc{Kt,Vt}(Vector{Kt}(row), Vector{Kt}(col), Vector{Vt}(val), A)
end

#=
emptyAssoc: canonical empty Assoc — String keys, numeric sentinel.
=#
function emptyAssoc()
    Assoc{String,Float64}(String[], String[], Float64[1.0], spzeros(Float64, 0, 0))
end

function size(A::Assoc)
    return size(A.A)
end

function nnz(A::Assoc)
    return nnz(A.A)
end

function isempty(A::Assoc)
    return isempty(A.A)
end

#=
Factory constructor (3-arg public API): processes D4M delimited strings, arrays of
keys/values, and scalars. Returns a concretely-typed Assoc{K,V}.
=#
Assoc(rowIn::StringOrNumArray, colIn::StringOrNumArray, valIn::StringOrNumArray) =
    Assoc(rowIn, colIn, valIn, min)

function Assoc(rowIn::StringOrNumArray, colIn::StringOrNumArray, valIn::StringOrNumArray,
               funcIn::Function)
    if isempty(rowIn) || isempty(colIn) || isempty(valIn)
        return Assoc{String,Float64}(String[], String[], Float64[1.0],
                                     spzeros(Float64, 0, 0))
    end

    if isa(rowIn, Number)
        rowIn = [rowIn]
    end
    if isa(colIn, Number)
        colIn = [colIn]
    end
    if isa(valIn, Number)
        valIn = [valIn]
    end

    i = rowIn; j = colIn; v = valIn
    row = rowIn; col = colIn; val = valIn

    if isa(rowIn, AbstractString)
        row, _, i = StrUnique(rowIn)
    else
        row = sort!(unique(i))
        i = convert(AbstractArray{Int64}, [searchsortedfirst(row, x) for x in i])
    end

    if isa(colIn, AbstractString)
        col, _, j = StrUnique(colIn)
    else
        col = sort!(unique(j))
        j = convert(AbstractArray{Int64}, [searchsortedfirst(col, x) for x in j])
    end

    if isa(valIn, AbstractString)
        val, _, v = StrUnique(valIn)
    else
        val = sort!(unique(v))
        if isa(valIn[1], AbstractString)
            if val[1] == ""
                val = val[2:end]
                emptyidx = v .== ""
            else
                emptyidx = []
            end
            v = convert(AbstractArray{Int64}, [searchsortedfirst(val, x) for x in v])
            v[emptyidx] .= 0
        else
            if any(isa.(v, Float64))
                v = convert(AbstractArray{Float64}, v)
            else
                v = convert(AbstractArray{Int64}, v)
            end
        end
    end

    NMax = maximum([length(i) length(j) length(v)])
    if length(i) == 1
        i = convert(AbstractArray{Int64}, repeat(i, NMax))
    end
    if length(j) == 1
        j = convert(AbstractArray{Int64}, repeat(j, NMax))
    end
    if length(v) == 1
        v = convert(AbstractArray{Int64}, repeat(v, NMax))
    end

    if isa(val[1], AbstractString)
        A = sparse(i, j, v, length(row), length(col), min)
    else
        A = sparse(i, j, v, length(row), length(col), (+))
    end

    # Materialize concrete key type: convert SubString → String for string keys.
    if isa(row[1], AbstractString)
        row_k = Vector{String}(string.(row))
        col_k = Vector{String}(string.(col))
        K = String
    else
        K = typeof(row[1])
        row_k = Vector{K}(row)
        col_k = Vector{K}(col)
    end

    if isa(val[1], AbstractString)
        return Assoc{K,String}(row_k, col_k, Vector{String}(string.(val)), A)
    else
        return Assoc{K,Float64}(row_k, col_k, Float64[1.0], A)
    end
end

include("./Assoc/getindex.jl")
include("./Assoc/selectors.jl")
include("./Assoc/condense.jl")
include("./Assoc/operations.jl")
include("./Assoc/print.jl")
include("./Assoc/accessor.jl")
include("./Assoc/put.jl")
include("./Assoc/convert.jl")
include("./Assoc/broadcast.jl")
include("./Assoc/io.jl")
include("./Assoc/arrow_io.jl")
include("./Assoc/convertvals.jl")
include("./Assoc/bfs.jl")

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################
