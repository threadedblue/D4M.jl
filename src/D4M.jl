
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
            logical, str2num,  convertassoc, parseassoc,
            sqIn, sqOut,
            putAdj, putRow, putCol, putVal,
            getadj, getrow, getcol, getval, find,
            #saveassoc, loadassoc,
            OutDegree, InDegree,
            and, plus, minus, *, bounded,
            removediag, adjbfs

    include("Assoc.jl") # Associative Array

    #Helper functions for parsing
    include("parsinghelpers.jl")
    #Helper functions for working with strings and string arrays
    include("stringarrayhelpers.jl")

    #Reflects any changes in version; used to debug usage of Revise
    include("version.jl")
    export D4Mver


    if haskey(ENV,"JAVA_HOME")
        # Database functionality
        include("DB/DBserver.jl")
        include("DB/DBtable.jl")
        # Grapulo Calls
        include("DB/bfs.jl")
        include("DB/tablemult.jl")
        include("DB/jaccard.jl")
        include("DB/nmf.jl")    
        
        using JavaCall
        # be sure to keep adding stuff here, so we don't have to prepend calls w "D4M."
        export dbinit, dbsetup, ls, getindex, ispresent, deleteall, deleteprefix # DBserver
        export delete, toDBstring, getindex, addColCombiner, put, putTriple, getiterator, getsplits, addsplits, nnz # DBtable
        export makedegreetable, adjbfs, edgebfs, singlebfs # BFS
        export tablemult # tablemult
        export jaccard # jaccard
        export nmf # NMF

        println("Database capabilities loaded!")
    else
        println("Not loading database capabilities. If you would like to connect to a database, please set JAVA_HOME.")
        println("After setting JAVA_HOME, run:")
        println("D4Mpkg = Base.PkgId(\"D4M\"); Base.compilecache(D4Mpkg)")
    end

    println("D4M loaded!")

end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################




