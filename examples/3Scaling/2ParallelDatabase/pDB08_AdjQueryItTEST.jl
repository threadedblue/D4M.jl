# Query adjacency matrix in a database table using an iterator. This example queries all the elements of a set of starting vertices, calculates their degrees, and finds the maximum degree.

# Max elements in iterator.
MaxElem = 500

# Create array of starting vertices
Nv0 = 100
v0 = string.(ceil.(Int,10000*rand(Nv0,1)))

# Set up query iterator
TadjIt = getiterator(Tadj,MaxElem)

# Start query iterator
A = TadjIt[v0str,:]

# Initialize AinDeg to accumulate output
AinDeg = Assoc("","","")

# While there are still elements in A
while nnz(A) > 0
    # Compute in degree
    AinDeg = AinDeg + sum(str2num(A),1)
    
    # Get next query
    A = TadjIt[]
end

# Get vertex with the maximum degree
AmaxInDeg = (AinDeg == maximum(Adj(AinDeg)))