using SparseArrays

#=
condense : remove explicit zeros and empty rows/columns from Assoc A.

Drops explicit zeros from the sparse matrix, then identifies non-empty rows/columns.
This preserves the AA invariant (no fully-empty rows or columns) even when operations
like minus() accumulate values to zero.

Optimization: uses SparseMatrixCSC's colptr and rowval fields directly instead
of computing full row/column sums (which allocate dense vectors).
- Non-empty columns: colptr[j+1] > colptr[j]  → O(ncols)
- Non-empty rows:    unique(rowval)             → O(nnz)
=#
function condense(A::Assoc)
    M = A.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(A.A) : A.A

    dropzeros!(M)

    nonZeroCol = findall(j -> M.colptr[j+1] > M.colptr[j], 1:M.n)
    nonZeroRow = isempty(M.rowval) ? Int[] : sort!(unique(M.rowval))

    Newrow = A.row[nonZeroRow]
    Newcol = A.col[nonZeroCol]
    NewA   = M[nonZeroRow, nonZeroCol]

    return Assoc(Newrow, Newcol, A.val, NewA)
end

#=
deepCondense : remove empty row, column, and value mappings, return condensed Assoc.

Optimization: replaced pmap (distributed parallel map — extreme overhead for a simple
binary-search lookup) with a plain comprehension.
=#
function deepCondense(A::Assoc)
    Anew = condense(A)

    M = Anew.A isa Union{LinearAlgebra.Adjoint, LinearAlgebra.Transpose} ?
            SparseMatrixCSC(Anew.A) : Anew.A
    row, col, val = findnz(dropzeros!(M))

    uniVal = sort!(unique(val))
    # was: pmap(x -> searchsortedfirst(uniVal, x), val) — distributed overhead for a trivial lookup
    val = [searchsortedfirst(uniVal, x) for x in val]

    Anew = Assoc(copy(Anew.row), copy(Anew.col), copy(Anew.val[uniVal]), sparse(row, col, val))
    return Anew
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################
