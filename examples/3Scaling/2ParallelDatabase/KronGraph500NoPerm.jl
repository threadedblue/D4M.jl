function KronGraph500NoPerm(SCALE,EdgePerVertex)
    
    # Set the number of vertices and edges to be generated
    N = 2^SCALE
    M = round(EdgePerVertex * N)

    # Set R_MAT (2x2 Kronecker) coefficients
    A = 0.57
    B = 0.19
    C = 0.19
    D = 1-(A+B+C)

    # Initialize index arrays
    ij = ones(Int,2,M)

    # Normalize coefficients
    ab = A+B
    c_norm = C/(1-(A+B))
    a_norm = A/(A+B)

    # Loop over each scale
    for ib = 1:SCALE
        ii_bit = rand(1,M) .> ab
        jj_bit = rand(1,M) .> (c_norm * ii_bit + a_norm * .!(ii_bit))
        ij = ij + 2^(ib-1) * [ii_bit; jj_bit]
    end
    
    StartVertex = ij[1,:]
    EndVertex = ij[2,:]

    return StartVertex, EndVertex
end
