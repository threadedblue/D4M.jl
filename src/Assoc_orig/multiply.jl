import Base.*

#=

* : matrix multiply between two Assoc.

If there are Strings in Assoc Value mapping, the Assoc will be reduced to logical.

=#
function *(A::Assoc,B::Assoc)
    #Check A,B, if string => Logical
    At = A
    Bt = B
    if(!isa(A.val[1],Number))
        At = logical(A)
    end
    if(!isa(B.val[1],Number))
        Bt = logical(B)
    end
    ## A*B operation
    #Improve intersect with unique sorted sets
    ABintersect = sortedintersect(At.col,Bt.row)
    
#    if (size(ABintersect,1) == 0)
#        return Assoc([1],[1],0,(+))
#    end
    
#    AintMap = searchsortedmapping(ABintersect,At.col) 
#    BintMap = searchsortedmapping(ABintersect,Bt.row) 

    Aref = @spawn searchsortedmapping(ABintersect,At.col)
    Bref = @spawn searchsortedmapping(ABintersect,Bt.row)
    AintMap = fetch(Aref)
    BintMap = fetch(Bref)
#    AintMap, BintMap = sortedintersectmapping(At.col,Bt.row)

#    AintMap,BintMap = map(x -> searchsortedmapping(x[1],x[2]),[(ABintersect,At.col) (ABintersect, Bt.row)])
    Aref = @spawn At.A[:,AintMap]
    Bref = @spawn Bt.A[BintMap,:]
    AA = fetch(Aref)
    BB = fetch(Bref)

    ABA = AA*BB

    AB = Assoc(At.row,Bt.col,Array{Union{AbstractString,Number}}([1.0]),ABA)

    return condense(AB)
end

function Base.broadcast(::typeof(*),A::Assoc,B::Assoc)

    #Check A,B, if string => Logical
    At = A
    Bt = B
    if(!isa(A.val[1],Number))
        At = logical(A)
    end
    if(!isa(B.val[1],Number))
        Bt = logical(B)
    end

    #First, create the row and col of the intersection
    ABrow = sortedintersect(At.row,Bt.row)
    ABcol = sortedintersect(At.col,Bt.col)
    #Filling the sparse matrix with 
    
    AA = spzeros(size(ABrow,1), size(ABcol,1))
    rowMapping = searchsortedmapping(ABrow,At.row)
    colMapping = searchsortedmapping(ABcol,At.col)
    AA = At.A[rowMapping,colMapping]
    #AA = round(Int64,AA)
    
    BB = spzeros(size(ABrow,1), size(ABcol,1))
    rowMapping = searchsortedmapping(ABrow,Bt.row)
    colMapping = searchsortedmapping(ABcol,Bt.col)
    BB = Bt.A[rowMapping,colMapping]
    #BB = round(Int64,BB)
    
    ABA = AA .* BB
    ABA = sparse(ABA)
    return Assoc(ABrow,ABcol,promote([1.0],At.val)[1],ABA)
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

