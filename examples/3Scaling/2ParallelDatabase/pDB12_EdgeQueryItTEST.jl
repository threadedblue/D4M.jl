# Query incidence matrix in a database table using an iterator. This example queries all the elements of a set of starting vertices, calculates their degrees, and finds the maximum degree.

# Max elements in iterator.
MaxElem = 500

# Create array of starting vertices
Nv0 = 100
v0 = "Out|" .* string.(ceil.(Int,10000*rand(Nv0,1)))

# Set up query iterator
TedgeIt = getiterator(Tedge,MaxElem)

# Start query iterator
E= logical(TedgeIt[:,v0str])

# Initialize AinDeg to accumulate output
EinDeg = Assoc("","","")

# While there are still elements in E
while nnz(E) > 0

    global E, EinDeg

    # Compute in degree
    Etmp = logical(Tedge[getrow(E),:])
    EinDeg = EinDeg + sum(Etmp[:,StartsWith("In|")],1)
    
    # Get next query
    E = logical(TedgeIt[])
end

# Get vertex with the maximum degree
EmaxInDeg = (EinDeg == maximum(getadj(EinDeg)))