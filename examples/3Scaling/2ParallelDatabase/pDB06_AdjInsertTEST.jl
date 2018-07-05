# Insert graph data into an adjacency table.
using JLD

# Iterate through files
isdefined(:Nfile) || (Nfile = 8)
for i = 1:Nfile
    tic();

    # Create filename
    fname = "data/"*string(i)
    println("On file: "*string(i))

    # Load associative array.
    A = load(fname*".A.jld")["A"]

    # Insert associative array.
    put(Tadj,A)

    #Compute in and out degree.
    Aout_i = putCol(sum(A,2),convert(Array{Union{AbstractString,Number}},["OutDeg"]))
    Ain_i = putCol(sum(A,1)',convert(Array{Union{AbstractString,Number}},["InDeg"]))

    # Accumulate in and out degrees.
    put(TadjDeg,Aout_i)
    put(TadjDeg,Ain_i)
            
    insertTime = toc()
    println("Time: "*string(insertTime)*", Edges/sec: "*string((2*nnz(A)+nnz(Aout_i)+nnz(Ain_i))./insertTime))
    #println(['Time: ' num2str(insertTime) ', Edges/sec: ' num2str((2*nnz(A)+nnz(Aout_i)+nnz(Ain_i))./insertTime)]); 
end

println("Table entries: "*string(nnz(Tadj)));