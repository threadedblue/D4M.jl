#import Base.(==)
#=
== : get a new Assoc where all of the elements of input Assoc matches the given Element.
=#
(==)(A::Assoc,E::Union{AbstractString,Number}) = equal(A::Assoc,E::Union{AbstractString,Number})
function equal(A::Assoc, E::Union{AbstractString,Number})
    if (isa(E,Number) && (A.val == [1.0])  ) 
        tarIndex = E
    else
        tarIndex = searchsortedfirst(A.val,E)
        if !(E == Val(A)[tarIndex])
            tarIndex = 0
        end
    end
    
    rowkey, colkey, valkey = SparseArrays.findnz(A.A)
    mapping = find( x-> x == tarIndex, valkey)
    rows,cols,vals = find(A)

    Aout = Assoc(rows[mapping],cols[mapping],vals[mapping])

    # May not need this anymore
    if A.val==[1.0]
        Aout = putVal(Aout,A.val)
    end
    
    return Aout
end

==(E::Union{AbstractString,Number},A::Assoc) = (A == E)

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

