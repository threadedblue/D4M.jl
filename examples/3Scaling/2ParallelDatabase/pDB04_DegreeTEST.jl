# Calculate and plot in and out degrees of generated Kronecker Graph
using JLD,PyPlot

# Associative arrays to accumulate in and out degrees
Aall = Assoc("","","")

# Iterate through files
isdefined(:Nfile) || (Nfile = 8)
for i = 1:Nfile
    tic()
    fname = "data/"* string(i)
    
    # Load associative array
    A = load(fname*".A.jld")["A"]

    # Create associative arrays and accumulate degrees
    Aall = A + Aall

    pTime = toq()
    println("Sum Time: ", pTime)
    println("Edges/sec: ", string(nnz(A)/pTime))
end

# Plot out degree distribution
figure()
loglog(full(OutDegree(Aall))',"o")
xlabel("out degree")

# Plot out degree distribution
figure()
loglog(full(InDegree(Aall))',"o")
xlabel("in degree")