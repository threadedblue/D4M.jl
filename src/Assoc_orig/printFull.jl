#=
printFull : print Assoc in tabular form.
=#
function printFull(A::Assoc)
    if !isempty(A)
        display(full(A))
    else
        show(A)
    end

    return nothing
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
#                    Lauren Milechin (lauren.milechin@mit.edu)
########################################################

