#using SparseArrays, LinearAlgebra

#=
nnz: Return the number of nonzeros in an Associative Array
=#


function nnz(A::Assoc)

    if isa(A.A,LinearAlgebra.Adjoint)
        return nnz(A.A.parent)
    else
        return nnz(A.A)
    end
end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Lauren Milechin (lauren.milechin@mit.edu)
########################################################
