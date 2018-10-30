# Insert graph data into an adjacency table.
using JLD2

# Iterate through files
(@isdefined Nfile) || (Nfile = 8)
for i = 1:Nfile
    inserttime = @elapsed begin

        # Create filename
        fname = joinpath(Base.source_dir(),"data", string(i))
        println("On file: "*string(i))

        # Load associative array.
        E = loadassoc(fname*".E.jld")

        # Insert associative array.
        put(Tedge,E)

        #Compute in and out degree.
        Edeg = putCol(sum(E,1)',"Degree,")

        # Accumulate in and out degrees.
        put(TedgeDeg,Edeg)
            
    end
    
    println("Time: "*string(inserttime)*", Edges/sec: "*string((2*nnz(E)+nnz(Edeg))./inserttime))
end

println("Table entries: "*string(nnz(Tedge)));