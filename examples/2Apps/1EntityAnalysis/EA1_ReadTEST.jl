# Read entity data and organize into sparse associative array.

# Entity data are derived summaries obtained by from automated
# entity extraction algorithms applied to <1% of the NIST Rueters Corpus.
# See: http://trec.nist.gov/data/reuters/reuters.html

using JLD2,FileIO,PyPlot,SparseArrays

# Load data
file_dir = "./Entity.csv"
save_dir = "./Entity.jld2"
E = ReadCSV(file_dir)
print(E[1:5,:])

# Grab doc, entity, position, and type columns and combine type and entity with '/' seperator.
row,col,doc_val      = find(E[:,"doc,"])
row,col,entity_val   = find(E[:,"entity,"])
row,col,position_val = find(E[:,"position,"])
row,col,type_val     = find(E[:,"type,"])
typeEntity_val = CatStr(type_val, "/" , entity_val)

# Create a sparse associative array of all the data.
E = Assoc(doc_val,typeEntity_val,position_val)

# Show a few rows and plot a spy plot.
print(E[1:5,:])
figure()
spy(E')

# Save the associative array.
#save(save_dir,"E",E)
saveassoc(save_dir,E)