function CatKeyMul(A::Assoc,B::Assoc)
    if isa(col(A)[1],AbstractString) && isa(row(B)[1],AbstractString)
        AB = sortedintersect(A.col,B.row)
        A = A[:,AB]
        B = B[AB,:]
        rrr,ccc,vvv = findnz(adj(A*B))
        ABVal = Array{Union{AbstractString,Number}}(undef,length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABvalList = sortedintersect(col(A[r,:]),row(B[:,c]))
            if length(ABvalList) > 0
                val = join(ABvalList,";")*";"
                ABVal[i] = val
            end
        end
        return Assoc(row(A)[rrr],col(B)[ccc],ABVal)
    else
        return A*B
    end
    

end
