#=
Reduce all value to logical, checking if that cell is empty
=#

using SparseArrays

# spones may be depreciated in next version
logical(A::Assoc) = Assoc(copy(A.row),copy(A.col),promote([1.0],A.val)[1],spones(dropzeros!(copy(A.A))))


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

