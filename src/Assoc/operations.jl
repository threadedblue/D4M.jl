# Various mathematical operations
using LinearAlgebra, SparseArrays


#=
& / and : logical AND of A and B (intersection of keys, presence check)
=#
(&)(A::Assoc, B::Assoc) = and(A, B)
function and(A::Assoc, B::Assoc)
    ABrow = intersect(A.row, B.row)
    ABcol = intersect(A.col, B.col)

    rowMapping = searchsortedmapping(ABrow, A.row)
    colMapping = searchsortedmapping(ABcol, A.col)
    AA = LinearAlgebra.fillstored!(copy(A.A[rowMapping, colMapping]), 1)
    AA = round.(Int64, AA)

    rowMapping = searchsortedmapping(ABrow, B.row)
    colMapping = searchsortedmapping(ABcol, B.col)
    BB = LinearAlgebra.fillstored!(copy(B.A[rowMapping, colMapping]), 1)
    BB = round.(Int64, BB)

    ABA = (AA .& BB) * 1.0
    return Assoc(ABrow, ABcol, promote([1.0], A.val)[1], ABA)
end


#=
+ / plus : matrix addition for Assoc.

Fixes:
  1. Correctness bug: second `if` previously checked A.val again instead of B.val —
     B was never logicalized when A was numeric and B was string-valued.
  2. Performance: replaced incremental SparseMatrixCSC mutation (ABA[Arow,Acol] += At.A)
     with COO triple accumulation + single sparse() call, avoiding O(N²) re-sorting.
=#
+(A::Assoc, B::Assoc) = plus(A, B)
function plus(A::Assoc, B::Assoc)
    if isempty(A) return B end
    if isempty(B) return A end

    At = A.val != [1.0] ? logical(A) : A
    Bt = B.val != [1.0] ? logical(B) : B  # was: A.val != [1.0] (bug — always checked A)

    ABrow = sortedunion(At.row, Bt.row)
    ABcol = sortedunion(At.col, Bt.col)
    if isempty(ABrow) || isempty(ABcol)
        return Assoc([1], [1], 0, (+))
    end

    Arow = searchsortedmapping(At.row, ABrow)
    Acol = searchsortedmapping(At.col, ABcol)
    Brow = searchsortedmapping(Bt.row, ABrow)
    Bcol = searchsortedmapping(Bt.col, ABcol)

    # COO accumulation: remap each nonzero through the index maps, then build
    # the sparse matrix in one call — avoids O(N²) incremental CSC re-sorting.
    ai, aj, av = findnz(At.A)
    bi, bj, bv = findnz(Bt.A)

    I = vcat(Arow[ai], Brow[bi])
    J = vcat(Acol[aj], Bcol[bj])
    V = vcat(Float64.(av), Float64.(bv))

    ABA = sparse(I, J, V, length(ABrow), length(ABcol), +)
    AB = Assoc(ABrow, ABcol, [1.0], ABA)
    return condense(AB)
end


#=
- / minus : matrix subtraction for Assoc.

Two paths (matching D4M.py semantics):
1. Both numerical: arithmetic difference (A + (-B))
2. Otherwise: logical difference, preserving A's values where B has no entry

Performance: same COO accumulation fix as plus.
=#
-(A::Assoc, B::Assoc) = minus(A, B)
function minus(A::Assoc, B::Assoc)
    # Check if both are numerical: val is a single number, not a string or array of mixed types
    is_A_numerical = isa(A.val[1], Number) && length(A.val) == 1
    is_B_numerical = isa(B.val[1], Number) && length(B.val) == 1

    if is_A_numerical && is_B_numerical
        # Path 1: Arithmetic difference — negate B and add it
        B_negated = Assoc(copy(B.row), copy(B.col), [-B.val[1]], copy(B.A))
        return plus(A, B_negated)
    else
        # Path 2: Logical difference — keep A's values where B has no entry
        return _minus_typed(A, B)
    end
end

function _minus_typed(A::Assoc, B::Assoc)
    # Typed subtraction: keep A's values where A has entries and B doesn't
    # Convert B to logical for position marking
    Bt = B.val != [1.0] ? logical(B) : B

    ABrow = sortedunion(A.row, Bt.row)
    ABcol = sortedunion(A.col, Bt.col)
    if isempty(ABrow) || isempty(ABcol)
        return Assoc([1], [1], [1], sparse([],[],[], 1, 1))
    end

    Arow = searchsortedmapping(A.row, ABrow)
    Acol = searchsortedmapping(A.col, ABcol)
    Brow = searchsortedmapping(Bt.row, ABrow)
    Bcol = searchsortedmapping(Bt.col, ABcol)

    ai, aj, av = findnz(A.A)
    bi, bj, bv = findnz(Bt.A)

    # Map A entries with their original indices
    AI = Arow[ai]
    AJ = Acol[aj]
    AV = Float64.(av)

    # Map B entries (negated) for the subtraction
    BI = Brow[bi]
    BJ = Bcol[bj]
    BV = -Float64.(bv)

    # Combine: positive indices from A, negative from B
    I = vcat(AI, BI)
    J = vcat(AJ, BJ)
    V = vcat(AV, BV)

    # Accumulate: where A and B both have entries, they cancel out (A_idx + (-B_idx) = 0)
    # This gives us only positions where A has entries and B doesn't
    ABA = sparse(I, J, V, length(ABrow), length(ABcol), +)

    # Apply A's value semantics to the result
    if A.val == [1.0]
        # A is logical: result is logical
        AB = Assoc(ABrow, ABcol, [1.0], ABA)
    else
        # A is typed: preserve A's values
        AB = Assoc(ABrow, ABcol, A.val, ABA)
    end

    return condense(AB)
end


#=
* : matrix multiply between two Assoc.
String-valued inputs are reduced to logical before multiplication.

Performance: removed @spawn / fetch wrappers around searchsortedmapping and slicing.
For realistic matrix sizes the task-scheduling overhead of @spawn dominates the
computation, making the parallel version slower than a direct serial call.
=#
function *(A::Assoc, B::Assoc)
    At = !isa(A.val[1], Number) ? logical(A) : A
    Bt = !isa(B.val[1], Number) ? logical(B) : B

    ABintersect = sortedintersect(At.col, Bt.row)

    AintMap = searchsortedmapping(ABintersect, At.col)
    BintMap = searchsortedmapping(ABintersect, Bt.row)

    AA = At.A[:, AintMap]
    BB = Bt.A[BintMap, :]

    ABA = AA * BB
    AB = Assoc(At.row, Bt.col, [1.0], ABA)
    return condense(AB)
end


#=
transpose / adjoint : swap row and col keys, materialize the sparse transpose.

The previous implementation stored a lazy Transpose/Adjoint wrapper in A.A, making
the field type a Union{AbstractSparseMatrix, Adjoint, Transpose} — defeating type
inference on every subsequent operation. Materializing here keeps A.A concrete.
=#
function transpose(A::Assoc)
    return Assoc(A.col, A.row, A.val, copy(Transpose(A.A)))
end

function adjoint(A::Assoc)
    return Assoc(A.col, A.row, A.val, copy(Adjoint(A.A)))
end


#=
abs : element-wise absolute value of a numeric Assoc.

Fix: the previous implementation called deepcopy then set A.A on an immutable struct,
which is a compile-time error. Replaced with a new Assoc construction.
=#
function abs(A::Assoc)
    if isa(A.val[1], AbstractString)
        error("abs requires a numeric Assoc; got string-valued Assoc")
    end
    return Assoc(copy(A.row), copy(A.col), copy(A.val), Base.abs.(A.A))
end


#=
sqin : compute A'*A (in-degree co-occurrence).

Performance: removed unnecessary deepcopy — Assoc is immutable, deepcopy just
allocated a full copy that was immediately discarded when the type branch ran.
=#
function sqin(A::Assoc)
    B = isa(A.val[1], Number) ? A : logical(A)
    AA = B.A
    AAtAA = AA' * AA
    return Assoc(copy(B.col), copy(B.col), copy(B.val), copy(AAtAA))
end


#=
sqout : compute A*A' (out-degree co-occurrence).
=#
function sqout(A::Assoc)
    B = isa(A.val[1], Number) ? A : logical(A)
    AA = B.A
    AAtAA = AA * AA'
    return Assoc(copy(B.row), copy(B.row), copy(B.val), copy(AAtAA))
end


#=
sum(A, dim) : sum an Assoc along one dimension.
dim indexing is 1-based (Julia). D4M.py uses 0-based `axis`:
    sum(A, 1)  ==  A.sum(0)   (sums down the columns; one result row)
    sum(A, 2)  ==  A.sum(1)   (sums across the rows; one result column)
sum(A) with no dim sums every entry, as A.sum() does in D4M.py.
=#
function sum(A::Assoc, dim::Int64)
    if A.val != [1.0]
        A = logical(A)
    end
    if dim == 1
        return condense(Assoc(promote([1.0], A.row)[1], A.col,
                              promote([1.0], A.val)[1], sparse(sum(A.A, dims=1))))
    elseif dim == 2
        return condense(Assoc(A.row, promote([1.0], A.col)[1],
                              promote([1.0], A.val)[1], sparse(sum(A.A, dims=2))))
    end
end

function sum(A::Assoc)
    if A.val != [1.0]
        A = logical(A)
    end
    sum(A.A)
end


# Matrix multiply where resulting values are inner-dimension keys concatenated
function catkeymul(A::Assoc, B::Assoc)
    if isa(get_col(A)[1], AbstractString) && isa(get_row(B)[1], AbstractString)
        AB = sortedintersect(A.col, B.row)
        A = A[:, AB]
        B = B[AB, :]
        rrr, ccc, vvv = findnz(get_adj(A * B))
        ABVal = Array{Union{AbstractString,Number}}(undef, length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABvalList = sortedintersect(get_col(A[r, :]), get_row(B[:, c]))
            if length(ABvalList) > 0
                ABVal[i] = join(ABvalList, ";") * ";"
            end
        end
        return Assoc(get_row(A)[rrr], get_col(B)[ccc], ABVal)
    else
        return A * B
    end
end


# Matrix multiply where resulting values are previous values concatenated
function catvalmul(A::Assoc, B::Assoc)
    if isa(get_val(A)[1], AbstractString) && isa(get_val(B)[1], AbstractString)
        AB = sortedintersect(A.col, B.row)
        A = A[:, AB]
        B = B[AB, :]
        rrr, ccc, vvv = findnz(get_adj(A * B))
        ABVal = Array{Union{AbstractString,Number},1}(undef, length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABIntersect = sortedintersect(get_col(A[r, :]), get_row(B[:, c]))
            ABValList = Array{Union{AbstractString,Number},1}(undef, 0)
            for x in ABIntersect
                push!(ABValList, get_val(A[r, x * ","])[1])
                push!(ABValList, get_val(B[x * ",", c])[1])
            end
            if length(ABValList) > 0
                ABVal[i] = join(ABValList, ";") * ";"
            end
        end
        return Assoc(get_row(A)[rrr], get_col(B)[ccc], ABVal)
    else
        return A * B
    end
end


function OutDegree(A)
    if isa(A, Assoc)
        A = A.A
    end
    dout = sum(A, dims=2)
    dout_i = getindex.(findall(!iszero, dout), 1)
    dout_v = dout[dout_i]
    ndout = sum(sparse(dout_i, dout_v, 1), dims=1)
    return ndout
end

function InDegree(A)
    if isa(A, Assoc)
        A = A.A
    end
    din = sum(A, dims=1)
    din_i = getindex.(findall(!iszero, din), 1)
    din_v = din[din_i]
    ndin = sum(sparse(din_i, din_v, 1), dims=1)
    return ndin
end


#=
combine : merge two Assocs using a custom binary operation at colliding (row,col) keys.

Mirrors D4M.py's Assoc.combine(other, binary_op). Unlike plus(), this function:
  - Does NOT convert string-valued inputs to logical; actual values are preserved.
  - Resolves colliding (row,col) keys by applying binary_op to the actual values
    (not to internal index integers), so it works correctly for string AAs.
  - Keys present in only one input are carried through unchanged.

The right-overwrite semiring (a ⊕ b = b) is available as right_overwrite(A, B).
The left-overwrite  semiring (a ⊕ b = a) is available as left_overwrite(A, B).

Note: plus() remains the optimized path for standard numeric addition; use
combine() only when a non-standard semiring ⊕ is required.
=#
function combine(A::Assoc, B::Assoc, binary_op::Function)
    if isempty(A) return B end
    if isempty(B) return A end

    Arow, Acol, Aval = find(A)
    Brow, Bcol, Bval = find(B)

    A_cells = Dict{Tuple{Any,Any}, Any}(
        (Arow[i], Acol[i]) => Aval[i] for i in eachindex(Arow)
    )
    B_cells = Dict{Tuple{Any,Any}, Any}(
        (Brow[i], Bcol[i]) => Bval[i] for i in eachindex(Brow)
    )

    all_keys = union(keys(A_cells), keys(B_cells))

    rows = Any[]; cols = Any[]; vals = Any[]
    for key in all_keys
        r, c = key
        push!(rows, r); push!(cols, c)
        if haskey(A_cells, key) && haskey(B_cells, key)
            push!(vals, binary_op(A_cells[key], B_cells[key]))
        elseif haskey(A_cells, key)
            push!(vals, A_cells[key])
        else
            push!(vals, B_cells[key])
        end
    end

    return Assoc(rows, cols, vals)
end

# Right-overwrite semiring: a ⊕ b = b  (B's value replaces A's at colliding keys).
right_overwrite(A::Assoc, B::Assoc) = combine(A, B, (a, b) -> b)

# Left-overwrite semiring: a ⊕ b = a  (A's value is kept at colliding keys).
left_overwrite(A::Assoc, B::Assoc) = combine(A, B, (a, b) -> a)
