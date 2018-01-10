# Forming adjacency graphs.

# Read CSV file into associative array.
E = ReadCSV("Edge.csv")

# Get vertices and convert to numbers.
Ev = logical( E[:, StartsWith("V,")] )

# Compute vertex adjacency graph.
Av = sqIn(Ev)
printFull(Av)

# Compute edge adjacency graph.
Ae = sqOut(Ev)
printFull(Ae)