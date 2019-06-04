
#Module for D4M
module D4M

    print("using a local editing copy of D4M, test 2")

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
            #dbsetup, ls, 
            #nnz, delete, addColCombiner,
            #put, putTriple, getiterator,
            #getsplits, addsplits

    #Helper functions for working with strings and string arrays
    include("stringarrayhelpers.jl")

    include("Assoc.jl") # Associative Array

    #Helper functions for parsing
    include("parsinghelpers.jl")

    #Test to make sure you're using this package, not the official release
    include("localtest.jl")


    if haskey(ENV,"JAVA_HOME")
        using JavaCall
        export dbsetup, ls, delete, addColCombiner,
            put, putTriple, getiterator,
            getsplits, addsplits

        # Database functionality
        include("DBserver.jl")
        include("DBtable.jl")

    else
        print("Not loading database capabilities. If you would like to connect to a database, please set JAVA_HOME.")

    end

end


########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################




