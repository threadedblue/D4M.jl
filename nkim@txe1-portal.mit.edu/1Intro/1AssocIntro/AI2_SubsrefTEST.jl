println("This is a test on the subreferencing of Associative Array")

A = ReadCSV(joinpath(Base.source_dir(),"A.csv"))

# Get rows a and b.
println("Get rows a and b:")
A1r = A["a,b,",:];
printFull(A1r)

# Get rows containing a and columns 1 thru 3.
#TODO A2r = A("a *,",1:3)
# print(A2r)

# Get rows a to b.
println("Get rows a through b:")
A3r = A["a,:,b,",:]
printFull(A3r)

# Get rows starting with a or c.
println("Get rows starting with a or c:")
A4r = A[StartsWith("a,c,"),:]
printFull(A4r)

# Get cols a and b.
println("Get cols a and b:")
A1c = A[:,"a,b,"]
printFull(A1c)

# Get rows 1 thru 3 and cols containing a.
#TODO A2c = A(1:3,"a *,")
#print(A2c)

# Get cols a to b.
println("Get cols a through b:")
A3c = A[:,"a,:,b,"]
printFull(A3c)

# Get cols starting with a or c.
println("Get cols starting with a or c:")
A4c = A[:,StartsWith("a,c,")]
printFull(A4c)

# Get all values less than b.
#TODO A1v = (A < "b,")
#print(A1v)
