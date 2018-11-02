# Various ways to query subgraphs.

using JLD2,PyPlot,LinearAlgebra,SparseArrays

# Load data
file_dir = joinpath(Base.source_dir(),"./Entity.jld")
E = load(file_dir)["E"]
#E = loadassoc(joinpath(Base.source_dir(),"./Entity.jld2"))
E = logical(E)

# Compute entity (all facet pairs).
A = sqIn(E)
d = diag(getadj(A))
A = putAdj(A,getadj(A)-Diagonal(d))


# Compute normalized correlation.
i,j,v = findnz(getadj(A))
An = putAdj(A, sparse(i,j,v ./ min.(d[i],d[j])))

# Multi-facet queries.
x = "LOCATION/new york,"
p = StartsWith("PERSON/,")
printFull( (A[p,x] > 4) & (An[p,x] > 0.3))

# Triangles.
p0 = "PERSON/john kennedy,"

p1 = getrow(A[p,p0] + A[p0,p])
figure()
spy(A[p1,p1])

p2 = getrow( A[p1,p1] - (A[p,p0]+ A[p0,p]))
A[p2,p2] > 1
