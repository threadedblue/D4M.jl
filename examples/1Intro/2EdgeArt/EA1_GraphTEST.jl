csv_dir = “1Intro/2EdgeArt/Edge.csv“ #Pkg.dir("D4M") * "/examples/1Intro/2EdgeArt/Edge.csv" 
print(csv_dir)

E = ReadCSV(csv_dir);                       # Read CSV file into associative array.

Ev = logical( E[:, StartsWith("V,")] );        # Get vertices and convert to numbers.

Av = sqIn(Ev);                                 # Compute vertex adjacency graph.
print(Av);                               # Show in tabular form.

Ae = sqOut(Ev);                                # Compute edge adjacency graph.
print(Ae);                               # Show in tabular form.
