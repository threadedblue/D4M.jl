##Testing the Generation of Kronecker Graph
include("KronGraph500NoPerm.jl")
using PyPlot

# Set scale, average degree, and determine number of vertices and edges
SCALE = 12
EdgesPerVertex = 16
Nmax = 2.^SCALE
M = EdgesPerVertex .* Nmax

println("Maximum number of vertices: "*string(Nmax))
println("Number of edges: "*string(M))

# Generate graph and create adjacency matrix
v1,v2 = KronGraph500NoPerm(SCALE,EdgesPerVertex)
A = sparse(v1,v2,1)

# Visualize graph with spy plot
figure()
spy(A)

# Plot degree distribution
figure()
loglog(full(OutDegree(A))',"o")
xlabel("degree")
ylabel("count")