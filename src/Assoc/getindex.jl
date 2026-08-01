# Various ways to get part of an Associative Array (indexing, diag, or >,<,==)
using LinearAlgebra, SparseArrays

StringOrNumArray = Union{AbstractString,Array,Number}

#=
_keymask : find indices in sorted key array Akeys that are present in selection set.

Both Akeys and sel are sorted, so this uses sortedintersectmapping (merge-scan, O(N+M))
instead of the previous findall(x -> in(x, sel), Akeys) which was O(N×M).
=#
function _keymask(Akeys::Array, sel::Array)
    _, Bmap = sortedintersectmapping(sel, Akeys)
    return Bmap
end

#=
_keymask_set : find indices in Akeys matching elements in an unsorted selection array.

Uses a Set for O(1) membership, reducing findall from O(N×M) to O(N+M).
=#
function _keymask_set(Akeys::Array, sel::Array)
    sset = Set(sel)
    return findall(x -> x in sset, Akeys)
end

"""
getindex(A::Assoc, i::Array{Int64}, j::Array{Int64})

Base getindex — all higher-level overloads resolve to this.
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

PreviousTypes = Array{Int64}

# --- Array{Union{AbstractString,Number}} selectors ---
# Fix: was findall(x -> x in i, A.row) — O(N×M) linear scan on a sorted array.
# Now uses Set for O(1) lookup → O(N+M) total.
getindex(A::Assoc, i::Array{Union{AbstractString,Number}}, j::PreviousTypes) =
    getindex(A, _keymask_set(A.row, i), j)
getindex(A::Assoc, i::PreviousTypes, j::Array{Union{AbstractString,Number}}) =
    getindex(A, i, _keymask_set(A.col, j))
getindex(A::Assoc, i::Array{Union{AbstractString,Number}}, j::Array{Union{AbstractString,Number}}) =
    getindex(A, _keymask_set(A.row, i), _keymask_set(A.col, j))

PreviousTypes = Union{PreviousTypes,Array{Union{AbstractString,Number}}}

getindex(A::Assoc, i::Int64, j::PreviousTypes) = getindex(A, [i], j)
getindex(A::Assoc, i::PreviousTypes, j::Int64) = getindex(A, i, [j])
getindex(A::Assoc, i::Int64, j::Int64)         = getindex(A, [i], [j])

PreviousTypes = Union{PreviousTypes,Int64}

getindex(A::Assoc, i::Colon, j::PreviousTypes) = getindex(A, 1:size(A.row,1), j)
getindex(A::Assoc, i::PreviousTypes, j::Colon) = getindex(A, i, 1:size(A.col,1))
getindex(A::Assoc, i::Colon, j::Colon)         = getindex(A, 1:size(A.row,1), 1:size(A.col,1))

PreviousTypes = Union{PreviousTypes,Colon}

getindex(A::Assoc, i::AbstractRange, j::PreviousTypes) = getindex(A, collect(i), j)
getindex(A::Assoc, i::PreviousTypes, j::AbstractRange) = getindex(A, i, collect(j))
getindex(A::Assoc, i::AbstractRange, j::AbstractRange) = getindex(A, collect(i), collect(j))

PreviousTypes = Union{PreviousTypes,AbstractRange}

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

# D4M delimited-string selectors.
# Fix: was findall(x -> in(x, StrUnique(...)[1]), A.row) — O(N×M) linear in+set scan.
# Now uses sortedintersectmapping: both sel and A.row are sorted → O(N+M) merge scan.
getindex(A::Assoc, i::AbstractString, j::PreviousTypes) =
    getindex(A, _keymask(A.row, StrUnique(convertrange(A.row, i))[1]), j)
getindex(A::Assoc, i::PreviousTypes, j::AbstractString) =
    getindex(A, i, _keymask(A.col, StrUnique(convertrange(A.col, j))[1]))
getindex(A::Assoc, i::AbstractString, j::AbstractString) =
    getindex(A,
        _keymask(A.row, StrUnique(convertrange(A.row, i))[1]),
        _keymask(A.col, StrUnique(convertrange(A.col, j))[1]))

PreviousTypes = Union{PreviousTypes,AbstractString}

# Regex selectors
getindex(A::Assoc, i::Regex, j::PreviousTypes) = getindex(A, findall(x -> occursin(i, x), A.row), j)
getindex(A::Assoc, i::PreviousTypes, j::Regex) = getindex(A, i, findall(x -> occursin(j, x), A.col))
getindex(A::Assoc, i::Regex, j::Regex)         = getindex(A, findall(x -> occursin(i, x), A.row),
                                                               findall(x -> occursin(j, x), A.col))

PreviousTypes = Union{PreviousTypes,Regex}

# StartsWith selector — already uses binary search via searchsortedfirst/last
struct StartsWith
    inputString::AbstractString
end

function StartsWithHelper(Ar::Array{Union{AbstractString,Number}}, S::StartsWith)
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

getindex(A::Assoc, i::PreviousTypes, j::StartsWith) = getindex(A, i, StartsWithHelper(getcol(A), j))
getindex(A::Assoc, i::StartsWith, j::PreviousTypes) = getindex(A, StartsWithHelper(getrow(A), i), j)
getindex(A::Assoc, i::StartsWith, j::StartsWith)    = getindex(A, StartsWithHelper(getrow(A), i),
                                                                    StartsWithHelper(getcol(A), j))

PreviousTypes = Union{PreviousTypes,StartsWith}


function >(A::Assoc, E::Union{AbstractString,Number})
    tarIndex = (isa(E, Number) && A.val == [1.0]) ? E : searchsortedlast(getval(A), E)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A
    rowkey, colkey, valkey = findnz(M)
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
    rowkey, colkey, valkey = findnz(M)
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
    rowkey, colkey, valkey = findnz(M)
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
    rowkey, colkey, valkey = findnz(M)
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
    rowkey, colkey, valkey = findnz(M)
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
