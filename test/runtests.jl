# Functions that are useful for testing

using SafeTestsets, D4M, SparseArrays
#include("loadD4M.jl")

import Base.isequal

UnionArray = Array{Union{AbstractString,Number}}

# Check whether two associative arrays are "equal"
function isequal(A::Assoc,B::Assoc)
    pass = true
    why = ""
    rA,cA,vA = find(A)
    rB,cB,vB = find(B)
    adjA = A.A
    adjB = B.A

    # Check sizes of r,c,v match
    if ~(size(rA,1)==size(rB,1) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Row key sizes don't match:\n\tsize(rA): "*string(size(rA))*"\n\tsize(rB):"*string(size(rB))*"\n"
    end
    if ~(size(cA)==size(cB) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Column key sizes don't match:\n\tsize(cA): "*string(size(cA))*"\n\tsize(cB):"*string(size(cB))*"\n"
    end
    if ~(size(vA)==size(vB) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Value sizes don't match:\n\tsize(vA): "*string(size(vA))*"\n\tsize(vB):"*string(size(vB))*"\n"
    end

    # Check r,c,v match
    if ~all(rA .== rB)
        pass = false
        why = why*"Row keys don't match\n"
    end
    if ~all(cA .== cB)
        pass = false
        why = why*"Column keys don't match\n"
    end
    if ~all(vA .== vB)
        pass = false
        why = why*"Values don't match\n"
    end

    # Check sparse matrices match
    if ~(adjA == adjB)
        pass = false
        why = why*"Sparse matrices don't match\n"
    end

    if ~pass
        println(why)
    end

    return pass
end

# Type and size testing of Assoc and its components
function testassoc(A)
    pass = true
    why = ""

    # Check is A is correct data type
    if ~isa(A,Assoc)
        pass = false
        why = why*"Assoc wrong type: "*string(typeof(A))*"\n"
    end

    # Check row,col,val are correct data type
    if ~isa(A.row,UnionArray)
        pass = false
        why = why*"Row wrong type: "*string(typeof(A.row))*"\n"
    end
    if ~isa(A.col,UnionArray)
        pass = false
        why = why*"Col wrong type: "*string(typeof(A.col))*"\n"
    end
    if ~isa(A.val,UnionArray)
        pass = false
        why = why*"Val wrong type: "*string(typeof(A.val))*"\n"
    end

    # Check sparse matrix is right data type
    if ~isa(A.A,SparseMatrixCSC)
        pass = false
        why = why*"Sparse matrix wrong type: "*string(typeof(A.A))*"\n"
    end

    # Check size of row and col arrays match dimensions of sparse matrix
    if ~length(A.row) == size(A.A,1)
        pass = false
        why = why*"Row length does not match sparse matrix dimension 1:\n\tlength(A.row): "*string(length(A.row))*"\n\tsize(A.A,1): "*string(size(A.A,1))*"\n"
    end
    if ~length(A.col) == size(A.A,2)
        pass = false
        why = why*"Col length does not match sparse matrix dimension 2:\n\tlength(A.col): "*string(length(A.col))*"\n\tsize(A.A,2): "*string(size(A.A,2))*"\n"
    end

    # Check that numeric values are in sparse matrix, not in A.val
    if ~isempty(A) && ~(!all(isa.(A.val,Number)) || A.val == [1.0])
        pass = false
        why = why*"Numeric values in wrong place"
    end

    if ~pass
        println(why)
    end

    return pass
end

function testassoc(A,B)
    pass = true
    pass = pass && testassoc(A)
    pass = pass && isequal(A,B)
end

# Run Tests
@testset "All Tests" begin
    include("../src/walk4CSV.jl")
end