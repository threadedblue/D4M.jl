function CatValMul(A::Assoc,B::Assoc)
    if isa(getval(A)[1],AbstractString) && isa(getval(B)[1],AbstractString)
        AB = sortedintersect(A.col,B.row)
        A = A[:,AB]
        B = B[AB,:]
        rrr,ccc,vvv = findnz(getadj(A*B))
        ABVal = Array(Union{AbstractString,Number},length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABIntersect = sortedintersect(getcol(A[r,:]),getrow(B[:,c]))
            ABValList = Array{Union{AbstractString,Number},1}
            print(ABIntersect)
            for x in ABIntersect
                print(x)
                push!(ABValList,getval(A[r,x*","])[1])
                push!(ABValList,getval(B[x*",",c])[1])
            end
            if length(ABValList) > 0
                val = join(ABValList,";")*";"
                ABVal[i] = val
            end
        end
        return Assoc(getrow(A)[rrr],getcol(B)[ccc],ABVal)
    else
        return A*B
    end
    

end
