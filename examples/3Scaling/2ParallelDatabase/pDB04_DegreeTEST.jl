# Calculate and plot in and out degrees of generated Kronecker Graph
using JLD2,PyPlot

# Associative arrays to accumulate in and out degrees
Aall = Assoc("","","")

# Iterate through files
(@isdefined Nfile) || (Nfile = 8)
for i = 1:Nfile
    global Aall
    ptime = @elapsed begin
        fname = joinpath(Base.source_dir(),"data", string(i))
        
        # Load associative array
        A = loadassoc(fname*".A.jld")

        # Create associative arrays and accumulate degrees
        Aall = A + Aall
    end
    
    println("Sum Time: ", ptime)
    println("Edges/sec: ", string(nnz(A)/ptime))
end

# Plot out degree distribution
figure()
loglog(convert(Array,OutDegree(Aall)'),"o")
xlabel("out degree")

# Plot out degree distribution
figure()
loglog(convert(Array,InDegree(Aall)'),"o")
xlabel("in degree")