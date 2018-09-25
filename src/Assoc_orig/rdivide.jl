#import Base./

#=
 ./ : Elementwise divide for Assoc
=#
#(./)(A::Assoc,B::Assoc) = divide(A::Assoc,B::Assoc)
function Base.broadcast(::typeof(/),A::Assoc,B::Assoc)
    #First, create the row and col of the intersection
    ABrow = sortedintersect(A.row,B.row)
    ABcol = sortedintersect(A.col,B.col)
    #Filling the sparse matrix with 

    AA = spzeros(size(ABrow,1), size(ABcol,1))
    rowMapping = searchsortedmapping(ABrow,A.row)
    colMapping = searchsortedmapping(ABcol,A.col)
    AA = A.A[rowMapping,colMapping]
    #AA = round(Int64,AA)

    BB = spzeros(size(ABrow,1), size(ABcol,1))
    rowMapping = searchsortedmapping(ABrow,B.row)
    colMapping = searchsortedmapping(ABcol,B.col)
    BB = B.A[rowMapping,colMapping]
    #BB = round(Int64,BB)

    # Because of division by zero, sparse arrays fill with NaN's and Infs.
    AB = AA ./ BB
    nzvals = nonzeros(AB)
    nzvals[.~isfinite.(nzvals)] .= 0
    AB = dropzeros!(AB)

    return Assoc(ABrow,ABcol,promote([1.0],A.val)[1],AB)
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

