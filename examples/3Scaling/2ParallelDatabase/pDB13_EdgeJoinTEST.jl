# Show how to do joins. First joins on two distinct columns, then joins on a range of columns.
using PyPlot

# Set max elements in iterator
MaxElem = 1000

# Pick two columns to join
col1 = "In|1,"
col2 = "In|100,"

# Find all rows with these columns
E1 = Tedge[Row(Tedge[:,col1]),:]
E2 = Tedge[Row(Tedge[:,col2]),:]
Ejoin = E2[:,Col(E1)]

# Display
figure()
spy(Ejoin)
axis("auto")
xlabel("vertex")
ylabel("edge")

# Now we are finding all the out vertices with in vertices of both 111 and 222

# Set column ranges
colRange1 = StartsWith("In|111,")
colRange2 = StartsWith("In|222,")
 
# Set up query iterators
TedgeIt1 = getiterator(Tedge,MaxElem)
TedgeIt2 = getiterator(Tedge,MaxElem)

# Start first query iterator
E1 = logical(TedgeIt1[:,colRange1])
E1outDeg = Assoc("","","")

while nnz(E1) > 0
    # Combine
    E1 = logical(Tedge[Row(E1),:]); 
    E1outDeg = E1outDeg + sum(E1[:,StartsWith("Out|")],1)
    # Run next query iterator
    E1 = logical(TedgeIt1[])
end

# Start second query iterator
E2 = logical(TedgeIt2[:,colRange2])
E2outDeg = Assoc("","","")

while nnz(E2) > 0
    # Combine
    E2 = logical(Tedge[Row(E2),:]); 
    E2outDeg = E2outDeg + sum(E2[:,StartsWith("Out|")],1)
    # Run next query iterator
    E2 = logical(TedgeIt2[])
end

# Add together
E12outDeg = E1outDeg + E2outDeg
# Join columns
EjoinRange = E12outDeg[:,Col(E2outDeg[:,Col(E1outDeg)])]