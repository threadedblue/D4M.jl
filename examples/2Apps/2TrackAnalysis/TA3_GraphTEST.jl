# Compute tracks from entity edge data.

using JLD
include("findtracks.jl")
include("findtrackgraph.jl")

# Load edge incidence matrix.
E = load("Entity.jld")["E"]
E = logical(E)

# Set prefixes
p = StartsWith("PERSON/,")
t = StartsWith("TIME/,")
x = StartsWith("LOCATION/,")

# Build entity tracks with routine.
A = findtracks(E,t,p,x)

# Track Graph
G = findtrackgraph(A)
print(G > 5)
spy(G)

# Track graph pattern
o = "ORGANIZATION/international monetary fund,"
p = StartsWith("PERSON/,")
Go = findtrackgraph(A[:,Col(E[Row(E[:,o]),p])]);

print((Go > 2) & ((Go ./ G) > 0.2))