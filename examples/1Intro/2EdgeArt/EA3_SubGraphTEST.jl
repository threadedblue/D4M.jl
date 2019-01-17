# Show some associative array math.

# Read CSV file into associative array, get vertices and convert to numbers.
E = ReadCSV(joinpath(Base.source_dir(),"Edge.csv"))
Ev = logical( E[:, StartsWith("V,")] )

# Get orange and green edges
EvO = Ev[StartsWith("O,"),:]
EvG = Ev[StartsWith("G,"),:]

# Compute (empty) vertex adjacency graph.
AvOG = transpose(EvO) * EvG
printFull(AvOG)

# Compute edge adjacency graph.
AeOG = EvO * transpose(EvG)
printFull(AeOG)

# Compute edge adjacency graph preserving keys.
AeOG = CatKeyMul(EvO,transpose(EvG))
printFull(AeOG)