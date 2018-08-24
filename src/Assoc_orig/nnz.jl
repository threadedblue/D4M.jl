#import Base.nnz
using SparseArrays

#=
nnz: Return the number of nonzeros in an Associative Array
=#


function nnz(A::Assoc)
    return nnz(A.A)
end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Lauren Milechin (lauren.milechin@mit.edu)
########################################################
