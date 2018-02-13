# Show how to do joins. First joins on two distinct columns, then joins on a range of columns.
using PyPlot

# Set max elements in iterator
MaxElem = 1000

# Pick two columns to join
col1 = "1,"
col2 = "100,"

# Find all rows with these columns
Ajoin = Tadj[Row(sum(logical(Tadj[:,col1*col2]),2) == 2),:]

# Display
figure()
spy(Ajoin)
axis("auto")
xlabel("end vertex")
ylabel("start vertex")

# Set column ranges
colRange1 = StartsWith("111,")
colRange2 = StartsWith("222,")
 
# Set up query iterators
TadjIt1 = getiterator(Tadj,MaxElem)
TadjIt2 = getiterator(Tadj,MaxElem)

# Start first query iterator
A1 = logical(TadjIt1[:,colRange1])
A1outDeg = Assoc("","","");

while nnz(A1) > 0
    # Combine
    A1outDeg = A1outDeg + sum(A1,2)
    # Run next query iterator
    A1 = logical(TadjIt1[])
end

# Start second query iterator
A2 = logical(TadjIt2[:,colRange2])
A2outDeg = Assoc("","","")

while nnz(A2) > 0
    # Combine
    A2outDeg = A2outDeg + sum(A2,2)
    # Run next query iterator
    A2 = logical(TadjIt2[])
end

# Join columns
AjoinRange = Tadj[Row(A1outDeg[Row(A2outDeg),:]),:]