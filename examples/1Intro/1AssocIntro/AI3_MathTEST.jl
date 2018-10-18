using SparseArrays, LinearAlgebra

println("This file demos some of the mathematical operations on Associative Array")

A = ReadCSV("A.csv")
A = logical(A)
printFull(A)

# Sum down rows and across columns
print(sum(A,1))
print(sum(A,2))


# Compute a simple join
Aa = A[:,"a,"]
Ab = A[:,"b,"]
Aab = nocol(Aa) & nocol(Ab)

# Compute a histogram (facets) of other columns that are in rows with both a and b
F =  ( Aab )' * A;
printFull(F)

# Compute normalized histogram
Fn = F ./ sum(A,1)
printFull(Fn)

# Compute correlation
AtA = sqIn(A)
d = diag(adj(AtA))
AtA = putAdj(AtA,adj(AtA) - sparse(diagm(0 => d)))
printFull(AtA)
