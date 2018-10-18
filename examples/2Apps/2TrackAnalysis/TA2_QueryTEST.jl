# Compute tracks from entity edge data.
using JLD2
include("FindTracks.jl")

# Load edge incidence matrix.
# Load the data file
file_dir = "./Entity.jld2"
E = loadassoc(file_dir)
#E = load("Entity.jld")["E"]
Es = E
A = logical(E)

# Set prefixes
p = StartsWith("PERSON/,")
t = StartsWith("TIME/,")
x = StartsWith("LOCATION/,")

# Build entity tracks with routine.
A = findtracks(E,t,p,x)

# Track queries (Where have Michael Chang and Javier Sanchez been when?)
p1 = "PERSON/michael chang,"
p2 = "PERSON/javier sanchez,"
printFull( A[:,p1*p2] )

# Track windows (Who was in Austria during this time?)
t = "TIME/1996-09-03,:,TIME/1996-09-06,"
x = "LOCATION/austria"
col(A[t,:] == x)