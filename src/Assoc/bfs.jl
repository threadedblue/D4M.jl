# TODO make consistent with Graphulo's degree count, which only adds 1 (like logical)

function removediag(Ainput::Assoc)
    # A helper function to remove the diagonal of a square Assoc.
    # TODO make something that's not a cheap workaround

    # First, find the diagonal
    Adiag = []
    for v in 1:length(Ainput.row)
        # TODO check that there is an entry, before trying to index into it
        push!(Adiag, find(Ainput[v, v])[3][1])
    end
    AdiagAssoc = Assoc(Ainput.row, Ainput.col, Adiag)

    # Then, subtract this from the original matrix
    Anodiag = Ainput - AdiagAssoc

    # Finally, remove any zeroes from the SparseArray
    dropzeros!(Anodiag.A)

    return Anodiag
end

function adjbfs(A::Assoc, v0::AbstractString, numsteps::Number, minDegree = 1::Number, maxDegree = 2^31 - 1::Number; takeunion = false, nodiag = false)
    # TODO use native outdeg / indeg methods
    # (Try to) Automatically compute the outdegrees.
    # If nodiag is true, then the diagonal of the adjacency matrix will be ignored. (Handy when the diagonal represents edge counts, rather than self-loops)
    if nodiag
        Anodiag = removediag(A)
        Adeg = sum(Anodiag, 1)
    else
        Anodiag = A
        Adeg = sum(A, 1)
    end

    return adjbfs(Anodiag, Adeg, v0, numsteps, minDegree, maxDegree; takeunion = takeunion)

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

# function edgebfs(A::Assoc, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, EDegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false; takeunion = false)

#     # original Matlab documnetation:
#     # function [vk,uk,Ek] = EdgeBFS(E,startPrefix,endPrefix,prefixSep,Edeg,v0,k,dmin,dmax,takeunion)
#         # Out-degree-filtered Breadth First Search on Incidence Assoc/DB.
#         # Conceptually k iterations of: v0 ==startPrefix==> edge ==endPrefix==> v1
#         # Input:
#         #   E           - Incidence Assoc or Database Table
#         #   startPrefix - "Out" node prefix from nodes to edges, e.g. 'out,'
#         #   endPrefix   - "In" node prefix from edges to nodes, e.g. 'in,'
#         #   prefixSep   - Separator between node prefix and node, e.g. '|'
#         #   Edeg        - Assoc or DB Table of node out-degrees, e.g. sum(E,1).'
#         #                 Ex format: ('out|v1,','Degree,',2), ('in|v1,','Degree,',1)
#         #   v0          - Starting vertex set, e.g. 'v4,v5,'
#         #   k           - Number of BFS steps
#         #   dmin        - Minimum allowed out-degree, e.g. 1
#         #   dmax        - Maximum allowed out-degree, e.g. Inf
#         #   takeunion   - false to return nodes reachable in EXACTLY k steps;
#         #                 true to return nodes reachable in UP TO k steps
#         # Output:
#         #   vk - Nodes reachable in exactly k steps (up to k steps if takeunion=true)
#         #   uk - (optional) Nodes searched from to obtain the vk nodes that pass the out-degree filter
#         #   Ek - (optional) Incidence subgraph of edges from uk nodes to vk nodes
#         #        Note: Row(Ek) are edges traversed
        
#         # To consider: can add degreeColumn fairly easily, but I doubt users need it.
        
#     vk = v0
#     if takeunion
#         vkall = vk
#         ukall = ""
#         Ekall = Assoc("", "", "")
#     end
        
#     for i = 1:k
#         if isempty(vk) # meaning no nodes reachable from previous step's uk (or v0 is '').
#             println("Stopped BFS after step " * string(i) * "; no nodes in search set.")
#             Ek = Assoc("", "", "")
#             uk = ""
#             break
#         end
#             # Filter vk by node out-degrees into uk.
#         uk = Row(dmin <= str2num(Edeg(CatStr(startPrefix, prefixSep, vk), :)) <= dmax)
#         if isempty(uk)
#             println("Stopped BFS after step " * string(i) * "filtering; all nodes filtered away.")
#             Ek = Assoc("", "", "")
#             vk = ""
#             break      # All nodes filtered out.
#         end
#         [~,uk] = SplitStr(uk, prefixSep)   # uk is non-empty
#         if takeunion && nargout >= 2
#             ukall = StrUnique([ukall uk])
#         end
        
#             # Get edges starting from uk.
#         ek = Row(E(:, CatStr(startPrefix, prefixSep, uk)))
#             # Note: The following section will never occur by construction of the degree
#             # table Edeg.  If uk is non-empty, then there will be at least dmin edges present.
#         #     if isempty(ek)
#         #         disp('Stopped BFS after edge step; no edges present from uk.');
#         #         break
#         #     end
        
#             # Get nodes that ek goes into.
#         Ek = E(ek, :)   # Includes all nodes incident on edges ek.
#         if takeunion && nargout >= 3
#             [r,c,v] = find(Ek)
#             [r,c,v] = catFind(r, c, v, Ekall)
#             Ekall = Assoc(r, c, v) # Use @min collision function, instead of @plus
#         end
            
#             # Next nodes are the ones with endPrefix
#         vk = Col(Ek(:, StartsWith(endPrefix)))
#         if ~isempty(vk)
#             [~,vk] = SplitStr(vk, prefixSep)
#             if takeunion
#                 vkall = StrUnique([vkall vk])
#             end
#         end
#     end

#     if takeunion
#         vk = vkall
#         uk = ukall
#         Ek = Ekall
#     end
        
# end

    

function singlebfs(A::Assoc, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, ADegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)


    
end 
