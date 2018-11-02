# Compute tracks from entity edge data.

using JLD2, PyPlot
include("findtracks.jl")
include("findtrackgraph.jl")

# Load edge incidence matrix.
# Load the data file
file_dir = joinpath(Base.source_dir(),"../1EntityAnalysis/Entity.jld")
E = load(file_dir)["E"]
#E = loadassoc(file_dir)
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
figure()
spy(G)

# Track graph pattern
o = "ORGANIZATION/international monetary fund,"
p = StartsWith("PERSON/,")
Go = findtrackgraph(A[:,getcol(E[getrow(E[:,o]),p])]);

print((Go > 2) & ((Go ./ G) > 0.2))