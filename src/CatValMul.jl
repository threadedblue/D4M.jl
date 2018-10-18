function CatValMul(A::Assoc,B::Assoc)
    if isa(val(A)[1],AbstractString) && isa(val(B)[1],AbstractString)
        AB = sortedintersect(A.col,B.row)
        A = A[:,AB]
        B = B[AB,:]
        rrr,ccc,vvv = findnz(adj(A*B))
        ABVal = Array(Union{AbstractString,Number},length(rrr))
        for i in 1:length(rrr)
            r = rrr[i]
            c = ccc[i]
            ABIntersect = sortedintersect(col(A[r,:]),row(B[:,c]))
            ABValList = Array{Union{AbstractString,Number},1}
            print(ABIntersect)
            for x in ABIntersect
                print(x)
                push!(ABValList,val(A[r,x*","])[1])
                push!(ABValList,val(B[x*",",c])[1])
            end
            if length(ABValList) > 0
                val = join(ABValList,";")*";"
                ABVal[i] = val
            end
        end
        return Assoc(row(A)[rrr],col(B)[ccc],ABVal)
    else
        return A*B
    end
    

end
