# Various ways to query subgraphs.

using JLD,PyPlot

# Load data
E = load("./Entity.jld")["E"]
E = logical(E)

# Compute entity (all facet pairs).
A = sqIn(E)
d = diag(Adj(A))
A = putAdj(A,Adj(A)-diagm(d))


# Compute normalized correlation.
i,j,v = findnz(Adj(A))
An = putAdj(A, sparse(i,j,v ./ min.(d[i],d[j])))

# Multi-facet queries.
x = "LOCATION/new york,"
p = StartsWith("PERSON/,")
printFull( (A[p,x] > 4) & (An[p,x] > 0.3))

# Triangles.
p0 = "PERSON/john kennedy,"

p1 = Row(A[p,p0] + A[p0,p])
spy(A[p1,p1])

p2 = Row( A[p1,p1] - (A[p,p0]+ A[p0,p]))
A[p2,p2] > 1
