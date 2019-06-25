
#Module for D4M
module D4M

    using LinearAlgebra, SparseArrays, PyPlot, DelimitedFiles

    import SparseArrays: nnz, diag
    import Base: &, ==, >, <, -, *, +, /
    import Base: isless, getindex, isempty, print, size, sum, transpose,
            Array, Matrix, adjoint, broadcast
    import PyPlot: spy
    import JLD: writeas, readas

    export  Assoc,
            StartsWith,
            CatKeyMul, CatValMul,
            CatStr, SplitStr, NumStr,
            col2type, val2col,
            ReadCSV, WriteCSV,
            print, printFull, printTriple,
            norow, nocol,
            logical, str2num,
            sqIn, sqOut,
            putAdj, putRow, putCol, putVal,
            getadj, getrow, getcol, getval, find,
            #saveassoc, loadassoc,
            OutDegree, InDegree

    #Helper functions for working with strings and string arrays
    include("stringarrayhelpers.jl")

    include("Assoc.jl") # Associative Array

    #Helper functions for parsing
    include("parsinghelpers.jl")

    #Reflects any changes in verstiontest; used to debug usage of Revise
    include("versiontest.jl")
    export testD4Mver


    if haskey(ENV,"JAVA_HOME")
        # Database functionality
        include("DBserver.jl")
        include("DBtable.jl")
        # Grapulo Calls
        include("Graphulo/bfs.jl")
        include("Graphulo/tablemult.jl")
                
        
        using JavaCall
        # be sure to keep adding stuff here, so we don't have to prepend calls w "D4M."
        export dbinit, dbsetup, ls, getindex # DBserver
        export delete, toDBstring, getindex, addColCombiner, put, putTriple, getiterator, getsplits, addsplits, nnz # DBtable
        export adjbfs, edgebfs, singlebfs # BFS
        export tablemult # tablemult

        println("Database capabilities loaded!")

    else
        println("Not loading database capabilities. If you would like to connect to a database, please set JAVA_HOME.")

    end

end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################




