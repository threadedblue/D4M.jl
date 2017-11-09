#=
printTriple : return A in triple String form: (r,c) v 
=#
function printTriple(A::Assoc)

    if !isempty(A)
        r,c,v = find(A)
        println.("(" .* string.(r) .* "," .* string.(c) .* ")\t".* string.(v))
    else
        show(A)
    end

    return nothing
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Lauren Milechin (lauren.milechin@mit.edu)
########################################################