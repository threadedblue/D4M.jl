function removediag(A::Assoc)
    # A helper function to remove the diagonal of a square Assoc.

    # First, find the diagonal
    Adiag = []
    for v in 1:length(A.row)
        # TODO check that there is an entry, before trying to index into it
        push!(Adiag, find(A[v, v])[3][1])
    end
    AdiagAssoc = Assoc(A.row, A.col, Adiag)

    # Then, subtract this from the original matrix
    Anodiag = A - AdiagAssoc
    return Anodiag
end

function adjbfs(A::Assoc, v0::AbstractString, numsteps::Number, minDegree = 1::Number, maxDegree = 2^31 - 1::Number; takeunion = false, nodiag = false)
    # (Try to) Automatically compute the outdegrees.
    # If nodiag is true, then the diagonal of the adjacency matrix will be ignored. (Handy when the diagonal represents edge counts, rather than self-loops)
    if nodiag
        Anodiag = removediag(A)
        Adeg = sum(Anodiag, 1)
    else
        Adeg = sum(A, 1)
    end

    return adjbfs(A, Adeg, v0, numsteps, minDegree, maxDegree; takeunion = takeunion)

end


function adjbfs(A::Assoc, Adeg::Assoc, v0::AbstractString, numsteps::Number, minDegree = 1::Number, maxDegree = 2^31 - 1::Number; takeunion = false)

    #AdjBFS(A,Adeg,AoutDegCol,v0,k,dmin,dmax,takeunion,outInRow,rowSep,inDegCol)
    # A - A
    # Adeg - ADegtable can be null
    # AoutDegCol
    # v0 - v0 (initial vertices)
    # k - numsteps
    # dmin - minDegree
    # dmax - maxDegree
    # takeunion - unused??
    # outInRow- unused for now
    # rowSep - unused for now
    # inDegCol - unused for now

    vk = v0
    Ak = Assoc("", "", "")

    if vk == ""
        println("No start nodes.")
    end

    if takeunion
        Akall = Assoc("", "", "")
    end

    for i = 1:numsteps
        # println("step " * string((i)))
        # println("vk " * string((vk)))
        
        if isa(vk, Array) && ndims(vk) == 0 # meaning no nodes reachable from previous step's uk (or v0 is '').
            Ak = Assoc("", "", "")
            println("Stopped BFS after step " * string(i) *  "; no nodes in search set.")
            break
        end


        ukAssoc = bounded(Adeg[:,vk], minDegree, maxDegree)
        uk = ukAssoc.col  # filtered for degree

        # println("uk " * string(uk))
        if ndims(uk) == 0
            Ak = Assoc("", "", "")
        else
            Ak = A[uk,:]   # submatrix within reach of filtered neighbors
            if takeunion
                Akall = Ak + Akall
            end
        end

        vk = Ak.col   # nodes exactly k hops away
    end
    if takeunion
        Ak = Akall
    end

    return Ak

end

function edgebfs(A::Assoc, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, EDegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)



    
end

function singlebfs(A::Assoc, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, ADegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)


    
end 
