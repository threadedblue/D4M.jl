#=
Reduce all value to logical, checking if that cell is empty
=#

using SparseArrays,LinearAlgebra

logical(A::Assoc) = Assoc(copy(A.row),copy(A.col),promote([1.0],A.val)[1],LinearAlgebra.fillstored!(dropzeros!(copy(A.A)),1))


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

