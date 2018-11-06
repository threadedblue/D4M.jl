# Compute graphs from entity edge data.

using JLD, PyPlot

file_dir = joinpath(Base.source_dir(),"./Entity.jld")
E = load(file_dir)["E"]
#E = loadassoc(joinpath(Base.source_dir(),"./Entity.jld"))
E = logical(E)

# Computing adjacency matrix for the Entity-Entity graph.
Ae = sqIn(E)
figure()
spy(Ae)

# Entity-entity graphs that preserve original values.
# Limit to people with names starting with j
p = StartsWith("PERSON/j,")
Ep = E[:,p]

# Correlate while preserving pedigree
Ap = CatKeyMul(Ep',Ep)
figure()
spy(Ap)

# Create document-document graph: documents that contain the same entities.
Ad = sqOut(Ep)
figure()
spy(Ad)