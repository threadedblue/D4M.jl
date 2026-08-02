# Various ways to get part of an Associative Array (indexing, diag, or >,<,==)
using LinearAlgebra, SparseArrays

#=
_keymask : find indices in sorted key array Akeys that are present in selection set.

Both Akeys and sel are sorted, so this uses sortedintersectmapping (merge-scan, O(N+M))
instead of the previous findall(x -> in(x, sel), Akeys) which was O(N×M).
=#
function _keymask(Akeys::AbstractVector, sel::AbstractVector)
    _, Bmap = sortedintersectmapping(collect(sel), collect(Akeys))
    return Bmap
end

#=
_keymask_set : find indices in Akeys matching elements in an unsorted selection array.

Uses a Set for O(1) membership, reducing findall from O(N×M) to O(N+M).
=#
function _keymask_set(Akeys::AbstractVector, sel::AbstractVector)
    sset = Set(sel)
    return findall(x -> x in sset, Akeys)
end

"""
getindex(A::Assoc, i::Array{Int64}, j::Array{Int64})

Base getindex — all higher-level dispatch resolves to this via _resolve().
"""
function getindex(A::Assoc, i::Array{Int64}, j::Array{Int64})
    if isempty(A.A)
        return Assoc([1], [1], 0, (+))
    end
    if A.val == [1.0]
        return condense(Assoc(A.row[i], A.col[j], A.val, A.A[i, j]))
    else
        return deepCondense(Assoc(A.row[i], A.col[j], A.val, A.A[i, j]))
    end
end

# Singular case (one index → row selector, select all columns)
getindex(A::Assoc, i::Any) = getindex(A, i, :)

#=
_resolve : convert any D4M selector into a Vector{Int64} of indices into A.row / A.col.

To add a new selector type (e.g. Between, EndsWith):
  1. Define the struct in selectors.jl
  2. Add one _resolve method below (or at the end of selectors.jl after the struct)
  No getindex cross-product overloads are needed.
=#
_resolve(::AbstractVector, i::AbstractVector{<:Integer})          = Vector{Int64}(i)
_resolve(keys::AbstractVector, i::Array{Union{AbstractString,Number}}) = _keymask_set(keys, i)
_resolve(keys::AbstractVector, i::Vector{String})                 = _keymask_set(keys, i)
_resolve(::AbstractVector,    i::Integer)                         = [Int64(i)]
_resolve(keys::AbstractVector, ::Colon)                           = collect(Int64, eachindex(keys))
_resolve(::AbstractVector,    i::AbstractRange{<:Integer})        = collect(Int64, i)
_resolve(keys::AbstractVector, i::AbstractString)                 =
    _keymask(keys, StrUnique(convertrange(keys, i))[1])
_resolve(keys::AbstractVector, i::Regex)                          =
    findall(x -> occursin(i, x), keys)
# StartsWith _resolve is defined after the struct below.

# Universal 2D getindex: resolve both selectors to integer indices, then call the base case.
# Julia dispatches to the more-specific (Array{Int64}, Array{Int64}) base before reaching here,
# so there is no infinite recursion for fully-resolved integer index arrays.
function getindex(A::Assoc, i, j)
    getindex(A, _resolve(A.row, i), _resolve(A.col, j))
end

function convertrange(Akeys, r::AbstractString)
    sep = r[end:end]
    idx = 1
    while occursin(sep * ":" * sep, r[idx:end])
        idx = findfirst(sep * ":" * sep, r)[1] + 1
        from = 1:idx-2
        to   = idx+2:length(r)
        if occursin(sep, r[1:idx-2])
            from = findprev(sep, r, idx-2)[1]:idx-2
        end
        if occursin(sep, r[idx+1:end-1])
            to = idx+2:findnext(sep, r, idx+2)[1]-1
        end
        newKeys = join(Akeys[searchsortedfirst(Akeys, r[from]):searchsortedlast(Akeys, r[to])], sep)
        if !isempty(newKeys)
            r = r[1:from[1]-1] * newKeys * r[to[end]+1:end]
        else
            r = r[1:from[end]+1] * r[to[1]:end]
        end
        idx = from[end] + length(newKeys)
    end
    return r
end

# StartsWith selector — uses binary search via searchsortedfirst/last
struct StartsWith
    inputString::AbstractString
end

function StartsWithHelper(Ar::AbstractVector, S::StartsWith)
    str_list = if S.inputString[end] == ','
        StrUnique(S.inputString)[1]
    else
        [S.inputString]
    end
    result_indice = Array{Int64,1}()
    for str in str_list
        lo = searchsortedfirst(Ar, str)
        hi = searchsortedlast(Ar, str * string(Char(255)))
        if lo <= hi
            append!(result_indice, lo:hi)
        end
    end
    return result_indice
end

_resolve(keys::AbstractVector, i::StartsWith) = StartsWithHelper(keys, i)


function >(A::Assoc, E::Union{AbstractString,Number})
    tarIndex = (isa(E, Number) && A.val == [1.0]) ? E : searchsortedlast(getval(A), E)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    _, _, valkey = findnz(M)
    mapping = findall(x -> x > tarIndex, valkey)
    rows, cols, vals = find(A)
    outA = Assoc(rows[mapping], cols[mapping], vals[mapping])
    if A.val == [1.0]
        outA = putVal(outA, A.val)
    end
    return outA
end

>(E::Union{AbstractString,Number}, A::Assoc) = (A < E)

function <(A::Assoc, E::Union{AbstractString,Number})
    tarIndex = (isa(E, Number) && A.val == [1.0]) ? E : searchsortedfirst(A.val, E)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    _, _, valkey = findnz(M)
    mapping = findall(x -> x < tarIndex, valkey)
    rows, cols, vals = find(A)
    outA = Assoc(rows[mapping], cols[mapping], vals[mapping])
    if A.val == [1.0]
        outA = putVal(outA, A.val)
    end
    return outA
end

<(E::Union{AbstractString,Number}, A::Assoc) = (A > E)

(==)(A::Assoc, E::Union{AbstractString,Number}) = equal(A, E)
function equal(A::Assoc, E::Union{AbstractString,Number})
    if isa(E, Number) && A.val == [1.0]
        tarIndex = E
    else
        tarIndex = searchsortedfirst(A.val, E)
        if !(E == getval(A)[tarIndex])
            tarIndex = 0
        end
    end
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    _, _, valkey = findnz(M)
    mapping = findall(x -> x == tarIndex, valkey)
    rows, cols, vals = find(A)
    Aout = Assoc(rows[mapping], cols[mapping], vals[mapping])
    if A.val == [1.0]
        Aout = putVal(Aout, A.val)
    end
    return Aout
end

==(E::Union{AbstractString,Number}, A::Assoc) = (A == E)

function bounded(A::Assoc, E1::Union{AbstractString,Number}, E2::Union{AbstractString,Number})
    tarIndex1 = (isa(E1, Number) && A.val == [1.0]) ? E1 : searchsortedfirst(A.val, E1)
    tarIndex2 = (isa(E2, Number) && A.val == [1.0]) ? E2 : searchsortedfirst(A.val, E2)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    _, _, valkey = findnz(M)
    mapping = findall(x -> tarIndex1 <= x <= tarIndex2, valkey)
    rows, cols, vals = find(A)
    outA = Assoc(rows[mapping], cols[mapping], vals[mapping])
    if A.val == [1.0]
        outA = putVal(outA, A.val)
    end
    return outA
end

function strictbounded(A::Assoc, E1::Union{AbstractString,Number}, E2::Union{AbstractString,Number})
    tarIndex1 = (isa(E1, Number) && A.val == [1.0]) ? E1 : searchsortedfirst(A.val, E1)
    tarIndex2 = (isa(E2, Number) && A.val == [1.0]) ? E2 : searchsortedfirst(A.val, E2)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    _, _, valkey = findnz(M)
    mapping = findall(x -> tarIndex1 < x < tarIndex2, valkey)
    rows, cols, vals = find(A)
    outA = Assoc(rows[mapping], cols[mapping], vals[mapping])
    if A.val == [1.0]
        outA = putVal(outA, A.val)
    end
    return outA
end

function diag(A::Assoc)
    if A.val == [1.0]
        return Assoc(A.row, A.col, A.val, dropzeros!(sparse(diagm(0 => diag(A.A)))))
    else
        return deepCondense(Assoc(A.row, A.col, A.val, sparse(diagm(0 => diag(A.A)))))
    end
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################
