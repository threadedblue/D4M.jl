#import Base.(>)
#=
== : get a new Assoc where all of the elements of input Assoc mataches the given Element.
=#
function >(A::Assoc, E::Union{AbstractString,Number})
    if (isa(E,Number) & (A.val ==[1.0])  )
        tarIndex = E
    else
        tarIndex = searchsortedlast(Val(A),E)
    end

    rowkey, colkey, valkey = findnz(A.A)
    mapping = findall( x-> x > tarIndex, valkey)
    rows, cols, vals = find(A)

    outA = Assoc(rows[mapping],cols[mapping],vals[mapping])

    if A.val==[1.0]
        outA = putVal(outA,A.val)
    end
    
    return outA
end

>(E::Union{AbstractString,Number},A::Assoc) = (A < E)

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

