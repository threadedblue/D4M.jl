#import Base.size

#=
size: Return the dimensions of the Associative Array
=#

function size(A::Assoc)
    return size(A.A)
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Lauren Milechin (lauren.milechin@mit.edu)
########################################################
