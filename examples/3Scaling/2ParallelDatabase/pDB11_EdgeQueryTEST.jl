# Query incidence matrix in a database table
using PyPlot

# Create a starting set of vertices
Nv0 = 100
v0 = ceil.(Int,10000*rand(Nv0,1))

# Convert to string list.
v0str = "Out|" .* string.(v0)

# Get degrees of vertices.
Edeg = str2num(TedgeDeg[v0str,:])

# Select vertices in an out degree range.
degMin = 5;  degMax = 10; 
degMax = max(degMax,minimum(getval(Edeg[:,"Degree,"]))+1)
v1str = getrow((Edeg[:,"Degree,"] > degMin) < degMax )

# Get vertex neighbors.
E = logical(Tedge[getrow(Tedge[:,v1str]),:])

figure()
spy(E)
xlabel("in/out vertex")
ylabel("edge")