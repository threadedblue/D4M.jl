# Setup for example.
include("KronGraph500NoPerm.jl")

# Define SCALE and EdgesPerVertex if not already defined
isdefined(:SCALE) || (SCALE = 12)
isdefined(:EdgesPerVertex) || (EdgesPerVertex = 16)

# Calculate number of vertices and edges
Nmax = 2 ^ SCALE
M = EdgesPerVertex * Nmax

# Create directory to write output
data_dir = "data/"
isdir(data_dir) || mkdir(data_dir)

# Create graphs and save in files
Nfile = 8
for i = 1:Nfile
    tic()

    # Create filename
    fname = data_dir * string(i)
    println("On file: "*string(i))
    
    #Reset Rand Seed
    srand(i)

    # Generate data
    v1,v2 = KronGraph500NoPerm(SCALE,round(Int,EdgesPerVertex/Nfile))

    # Convert to strings
    rowStr = join(string.(v1),'\n')
    colStr = join(string.(v2),'\n')
    valStr = join(string.(ones(Int,length(v1))),'\n')

    # Open files, write data, and close files
    fidRow = open(fname * "r.txt","w")
    fidCol = open(fname * "c.txt","w")
    fidVal = open(fname * "v.txt","w")

    write(fidRow,rowStr)
    close(fidRow)

    write(fidCol,colStr)
    close(fidCol)
    
    write(fidVal,valStr)
    close(fidVal)


    pTime = toq()
    println("Time: ", pTime)
    println("Edges/sec: ", string(length(v1) / pTime))
end


