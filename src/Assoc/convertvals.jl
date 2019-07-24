# Functions for changing the values of an associative array

#=
Reduce all value to logical, checking if that cell is empty
=#

using SparseArrays,LinearAlgebra

logical(A::Assoc) = Assoc(copy(A.row),copy(A.col),promote([1.0],A.val)[1],LinearAlgebra.fillstored!(dropzeros!(copy(A.A)),1))

function str2num(A::Assoc)
    r,c,v = find(A)
    v = parse.(Int, v) # TODO this won't work for string values- find numeric strings first, convert all others to 1
    # option to keep as is, or convert, i guess?
    # check out AI4
    A = Assoc(r,c,v)
end

# TODO: Write num2str

#=
convert all entries to a certain type
=#

function convertassoc(type::DataType, A::Assoc)
    valnew = convert.(type, A.val)
    valnew2 = Array{Union{AbstractString,Number},1}(valnew)
    return putVal(A, valnew2)
end

#=
If entries are strings, parse them into a number type
=#

function parseassoc(type::DataType, A::Assoc)
    valnew = parse.(type, A.val)
    valnew2 = Array{Union{AbstractString,Number},1}(valnew)
    return putVal(A, valnew2)
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################

