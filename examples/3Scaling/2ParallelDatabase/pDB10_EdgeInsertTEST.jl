# Insert graph data into an adjacency table.
using JLD2

# Iterate through files
isdefined(:Nfile) || (Nfile = 8)
for i = 1:Nfile
    tic();

    # Create filename
    fname = "data/"*string(i)
    println("On file: "*string(i))

    # Load associative array.
    E = load(fname*".E.jld")["E"]

    # Insert associative array.
    put(Tedge,E)

    #Compute in and out degree.
    Edeg = putCol(sum(E,1)',"Degree,")

    # Accumulate in and out degrees.
    put(TedgeDeg,Edeg)
            
    insertTime = toc()
    println("Time: "*string(insertTime)*", Edges/sec: "*string((2*nnz(E)+nnz(Edeg))./insertTime))
end

println("Table entries: "*string(nnz(Tedge)));