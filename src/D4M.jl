
#Module for D4M
module D4M
    using LinearAlgebra, SparseArrays, PyPlot, DelimitedFiles, Logging

    import SparseArrays: nnz, diag
    import Base: &, ==, >, <, -, *, +, /
    import Base: isless, getindex, isempty, print, size, sum, transpose,
            Array, Matrix, adjoint, broadcast
    import PyPlot: spy
    import JLD: writeas, readas

    export  Assoc, DBtable, DBtablePair,
            StartsWith,
            CatKeyMul, CatValMul,
            CatStr, SplitStr, NumStr,
            col2type, val2col,
            ReadCSV, WriteCSV, 
            # writeas, readas, 
            print, printFull, printTriple,
            norow, nocol,
            logical, str2num, num2str, convertvals,
            sqIn, sqOut,
            putAdj, putRow, putCol, putVal,
            getadj, getrow, getcol, getval, find,
            #saveassoc, loadassoc,
            OutDegree, InDegree, diag,
            bounded, strictbounded, adjbfs

    include("Assoc.jl") # Associative Array

    #Helper functions for parsing
    include("parsinghelpers.jl")
    #Helper functions for working with strings and string arrays
    include("stringarrayhelpers.jl")

     if haskey(ENV,"JAVA_HOME")
        # Database functionality
        include("DB/DBserver.jl")
        include("DB/DBtable.jl")
        # Grapulo Calls
        include("DB/bfs.jl")
        include("DB/tablemult.jl")
        include("DB/jaccard.jl")
        include("DB/nmf.jl")    
        include("DB/ktruss.jl")

  #       using JavaCall
        # be sure to keep adding stuff here, so we don't have to prepend calls w "D4M."
        export dbinit, dbsetup, ls # DBserver
        export delete, addColCombiner, put, putTriple, getiterator, getsplits, addsplits, nnz # DBtable
        export makedegreetable, adjbfs, edgebfs, singlebfs # BFS
        export tablemult # tablemult
        export jaccard # jaccard
        export nmf # NMF
        export ktrussadj, ktrussedge # ktruss
    else
        println("Not loading database capabilities. If you would like to connect to a database, please set JAVA_HOME.")
        println("After setting JAVA_HOME, run:")
        println("D4Mpkg = Base.PkgId(\"D4M\"); Base.compilecache(D4Mpkg)")
    end
end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################




