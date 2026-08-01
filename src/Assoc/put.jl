# putAdj: replace the sparse matrix in an Assoc, materializing non-CSC formats.
putAdj(A::Assoc, AA::SparseMatrixCSC)    = Assoc(copy(A.row), copy(A.col), copy(A.val), AA)
putAdj(A::Assoc, AA::AbstractSparseMatrix) = putAdj(A, SparseMatrixCSC(AA))
putAdj(A::Assoc, AA::AbstractMatrix)      = putAdj(A, sparse(AA))

# put for new key/value arrays — accept any AbstractVector so Vector{String} etc. dispatch correctly
putRow(A::Assoc, ARow::AbstractVector) = Assoc(ARow,        copy(A.col), copy(A.val), copy(A.A))
putCol(A::Assoc, ACol::AbstractVector) = Assoc(copy(A.row), ACol,        copy(A.val), copy(A.A))
putVal(A::Assoc, AVal::AbstractVector) = Assoc(copy(A.row), copy(A.col), AVal,        copy(A.A))

# put for scalar key/value: rebuilds triplets with the new scalar broadcast across all entries
function putRow(A::Assoc, ARow::Union{AbstractString,Number})
    r, c, v = find(A)
    Assoc(ARow, c, v)
end

function putCol(A::Assoc, ACol::Union{AbstractString,Number})
    r, _, v = find(A)
    Assoc(r, ACol, v)
end

function putVal(A::Assoc, AVal::Union{AbstractString,Number})
    r, c, _ = find(A)
    Assoc(r, c, AVal)
end

#=
nocol : replace column keys with sequential integers (removes string mapping)
=#
function nocol(A::Assoc)
    return condense(Assoc(A.row, Float64.(1:length(A.col)), A.val, A.A))
end

#=
norow : replace row keys with sequential integers (removes string mapping)
=#
function norow(A::Assoc)
    return condense(Assoc(Float64.(1:length(A.row)), A.col, A.val, A.A))
end
