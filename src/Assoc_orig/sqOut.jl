function sqOut(A::Assoc)
    AtA = deepcopy(A)
    if ! isa(A.val[1], Number)
        AtA = logical(A)
    end

    AA = getadj(AtA)
    AAtAA = AA * AA';

#=
    AtA.A = AAtAA;
    AtA.col = AtA.row
    return AtA
=#
    return Assoc(copy(AtA.row),copy(AtA.row),copy(AtA.val),AAtAA)
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################


