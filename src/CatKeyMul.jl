function CatKeyMul(A::Assoc,B::Assoc)
    if isa(getcol(A)[1],AbstractString) && isa(getrow(B)[1],AbstractString)
        AB = sortedintersect(A.col,B.row)
        A = A[:,AB]
        B = B[AB,:]
        rrr,ccc,vvv = findnz(getadj(A*B))
        ABVal = Array{Union{AbstractString,Number}}(undef,length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABvalList = sortedintersect(getcol(A[r,:]),getrow(B[:,c]))
            if length(ABvalList) > 0
                val = join(ABvalList,";")*";"
                ABVal[i] = val
            end
        end
        return Assoc(getrow(A)[rrr],getcol(B)[ccc],ABVal)
    else
        return A*B
    end
    

end
