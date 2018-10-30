#=
OutDegree : Calculate the out-degree distribution of graph A
InDegree : Calculate the in-degree distribution of graph A
=#

using SparseArrays

function OutDegree(A)
    if isa(A,Assoc)
        A = A.A
    end
    dout = sum(A,dims = 2)
    dout_i = getindex.(findall(!iszero,dout),1)
    dout_v = dout[dout_i]
    ndout = sum(sparse(dout_i,dout_v,1),dims = 1)
    return ndout
end

function InDegree(A)
    if isa(A,Assoc)
        A = A.A
    end
    din = sum(A,dims = 1)
    din_i = getindex.(findall(!iszero,din),1)
    din_v = din[din_i]
    ndin = sum(sparse(din_i,din_v,1),dims = 1)
    return ndin
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################