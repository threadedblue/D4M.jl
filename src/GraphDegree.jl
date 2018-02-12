#=
OutDegree : Calculate the out-degree distribution of graph A
InDegree : Calculate the in-degree distribution of graph A
=#

function OutDegree(A)
    if isa(A,Assoc)
        A = A.A
    end
    dout = sum(A,2)
    dout_i,dout_j,dout_v = findnz(dout)
    ndout = sum(sparse(dout_i,dout_v,1),1)
    return ndout
end

function InDegree(A)
    if isa(A,Assoc)
        A = A.A
    end
    din = sum(A,1)
    din_i,din_j,din_v = findnz(din)
    ndin = sum(sparse(din_i,din_v,1),1)
    return ndin
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################