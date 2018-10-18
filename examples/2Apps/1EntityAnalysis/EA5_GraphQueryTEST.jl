# Various ways to query subgraphs.

using JLD2,PyPlot,LinearAlgebra,SparseArrays

# Load data
E = loadassoc("./Entity.jld2")
E = logical(E)

# Compute entity (all facet pairs).
A = sqIn(E)
d = diag(adj(A))
A = putAdj(A,adj(A)-Diagonal(d))


# Compute normalized correlation.
i,j,v = findnz(adj(A))
An = putAdj(A, sparse(i,j,v ./ min.(d[i],d[j])))

# Multi-facet queries.
x = "LOCATION/new york,"
p = StartsWith("PERSON/,")
printFull( (A[p,x] > 4) & (An[p,x] > 0.3))

# Triangles.
p0 = "PERSON/john kennedy,"

p1 = row(A[p,p0] + A[p0,p])
figure()
spy(A[p1,p1])

p2 = row( A[p1,p1] - (A[p,p0]+ A[p0,p]))
A[p2,p2] > 1
