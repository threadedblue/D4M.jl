# Create associative arrays from sparse matrices
using JLD2

# Iterate through files
isdefined(:Nfile) || (Nfile = 8)
for i = 1:Nfile
    tic()

    # Create filename
    fname = "data/"* string(i)
    println("On file: "*string(i))

    # Open files, read data, and close files
    fidRow = open(fname * "r.txt","r")
    fidCol = open(fname * "c.txt","r")
    fidVal = open(fname * "v.txt","r")
    rowStr = readlines(fidRow)
    colStr = readlines(fidCol)
    valStr = readlines(fidVal)
    close(fidRow)
    close(fidCol)
    close(fidVal)

    # Construct adjacency associative array and sum duplicates
    A = Assoc(rowStr,colStr,1,(sum))
    save(fname*".A.jld","A",A)

    # Get versions with duplicates summed together
    rowStr,colStr,valStr = find(A)
    Nedge = length(rowStr)
    edgeBit = ceil(Int,log10(i.*Nedge))

    # Create identifier for each edge
    edgeStr = reverse.(lpad.(collect(((i-1).*Nedge)+(1:Nedge)),edgeBit,"0"))

    # Format out and in edge strings
    outStr = CatStr(fill("Out",length(rowStr)),"|",rowStr)
    inStr = CatStr(fill("In",length(colStr)),"|",colStr)

    # Create directed incidence Assoc
    E = Assoc([edgeStr; edgeStr],[outStr; inStr],[valStr; valStr]) 
    save(fname*".E.jld","E",E)

    assocTime = toq()
    println("Time: "*string(assocTime)*", Edges/sec: "*string(length(rowStr)./assocTime))
end


