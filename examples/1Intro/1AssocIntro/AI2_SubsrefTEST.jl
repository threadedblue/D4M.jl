println("This is a test on the subreferencing of Associative Array")

A = ReadCSV("A.csv")

# Get rows a and b.
A1r = A["a,b,",:];
print(A1r)

# Get rows containing a and columns 1 thru 3.
#TODO A2r = A("a *,",1:3)
# print(A2r)

# Get rows a to b.
A3r = A["a,:,b,",:]
print(A3r)

# Get rows starting with a or c.
A4r = A[StartsWith("a,c,"),:]
print(A4r)

# Get cols a and b.
A1c = A[:,"a,b,"]
print(A1c)

# Get rows 1 thru 3 and cols containing a.
#TODO A2c = A(1:3,"a *,")
#print(A2c)

# Get cols a to b.
A3c = A[:,"a,:,b,"]
print(A3c)

# Get cols starting with a or b.
A4c = A[:,StartsWith("a,c,")]
print(A4c)

# Get all values less than b.
#TODO A1v = (A < "b,")
#print(A1v)
