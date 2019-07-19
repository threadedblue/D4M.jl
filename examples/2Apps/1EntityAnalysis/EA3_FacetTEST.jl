# Entity facet search. Shows next most common terms.
using JLD, SparseArrays

# Load data
file_dir = joinpath(Base.source_dir(),"./Entity.jld")
#E = loadassoc(file_dir)
E = load(file_dir)["E"]
E = logical(E)

# Facet search: Finding entities that occur commonly with LOCATION/new york and PERSON/michael chang.
x = "LOCATION/new york,"
p = "PERSON/michael chang,"
F = ( nocol(E[:,x]) & nocol(E[:,p]))' * E
print(F' > 1 )

# Normalize the previous result.
Fn = F ./ sum(E,1)
print((Fn' > 0.02))