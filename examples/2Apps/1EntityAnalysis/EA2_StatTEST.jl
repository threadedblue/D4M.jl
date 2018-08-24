# Compute statistics on entity data

using JLD2,PyPlot

# Load the data file
file_dir = "./Entity.jld"
E = load(file_dir)["E"]

# Calculate number of entities in each category, then count the number of times each entity occurs.
print(sum(logical(col2type(E,"/")),1))
En = sum(logical(E),1)

# Plot the log-log plot of location frequencies. Notice the power-law distribution.
row,entity,count = find(En)
An = Assoc(count,entity,1)
figure()
loglog(full(sum(Adj(An[:,StartsWith("LOCATION/,")]),2)) ,"o")
