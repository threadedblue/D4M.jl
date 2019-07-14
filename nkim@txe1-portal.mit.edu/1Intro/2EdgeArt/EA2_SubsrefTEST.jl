# Show different wasy to index associative arrays.

# Read CSV file into associative array.
E = ReadCSV(joinpath(Base.source_dir(),"Edge.csv"))
printFull(E)

# Get orange edges.
Eo = E[(E[:,"Color,"] == "Orange" ).row,:]
printFull(Eo)

# Get orange and green edges.
Eog = E[ StartsWith("O,G,") ,:]
printFull(Eog)
