# Entity facet search. Shows next most common terms.
using JLD

# Load data
E = load("./Entity.jld")["E"]
E = logical(E)

# Facet search: Finding entities that occur commonly with LOCATION/new york and PERSON/michael chang.
x = "LOCATION/new york,"
p = "PERSON/michael chang,"
F = ( nocol(E[:,x]) & nocol(E[:,p]))' * E
print(F' > 1 )

# Normalize the previous result.
Fn = F ./ sum(E,1)
print((Fn' > 0.02))