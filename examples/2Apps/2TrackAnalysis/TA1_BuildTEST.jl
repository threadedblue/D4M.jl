# General approach to computing tracks from entity edge data.
using JLD

E = load("Entity.jld")["E"]
Es = E
E = logical(E)

# Show general purpose method for building tracks.
p = StartsWith("PERSON/,")      # Set entity range.
t = StartsWith("TIME/,")        # Set time range.
x = StartsWith("LOCATION/,")    # Set spatial range.
a = StartsWith("PERSON/,TIME/,LOCATION/,")

# Limit to edges with all three.
E3 = E[Row( sum(E[:,p],2) & sum(E[:,t],2) & sum(E[:,x],2) ),a]
printFull(E3)

# Collapse to get unique time and space for each edge and get triples.
edge,time  = find(  val2col(col2type(E3[:,t],"/"),"/")  )
edge,space = find(  val2col(col2type(E3[:,x],"/"),"/")  )

Etx = Assoc(edge,time,space)     # Combine edge, time and space.
Ext = Assoc(edge,space,time)     # Combine edge, space and time.


# Construct time tracks with matrix multiply.
At = CatValMul(transpose(Etx),E3[:,p])   
spy(At')
axis("auto")

# Construct space tracks with matrix multiply.
Ax = CatValMul(transpose(Ext),E3[:,p])  
spy(Ax')
axis("auto")