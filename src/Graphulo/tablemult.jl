using JavaCall
#=
tablemult : matrix multiply between two Accumulo tables.
=#
DBtableType = Union{DBtable,DBtablePair}

#= TableMult
Performs matrix multiply A * B of tables A and B
Inputs:
    AT: Should be the transpose of the matrix you want to multiply.
        If AT is a DBtablePair, the name1 will be taken to be AT. If you want name2 to be A, use AT = transpose(A)
    B: The second matrix you want to multiply
    C: String indicating the name of your new table.
Optional Input:
    CT: String indicating the name of transpose of result table, default empty string does not create transpose table
Key/Value Inputs:
    rowfilter: string indicating which rows of AT and B to perform the multiply on, formatted like D4M query strings
    colfilterAT: string indicating which columns of AT to perform the multiply on, formatted like D4M query strings
    colfilterB: string indicating which columns of B to perform the multiply on, formatted like D4M query strings
Ouptut:
Returns a binding to the new table (or table pair if transpose table is specified)
=#
function tablemult(AT::DBtableType,B::DBtableType,C::AbstractString,CT::AbstractString=""; rowfilter::AbstractString="",colfilterAT::AbstractString="",colfilterB::AbstractString="")

    if isa(AT,DBtablePair)
        ATname = AT.name1
    else
        ATname = AT.name
    end

    if isa(B,DBtablePair)
        Bname = B.name1
    else
        Bname = B.name
    end

    jcall(AT.DB.Graphulo,"TableMult", jlong, 
        (JString,JString,JString,JString,JString,JString,JString,jint,jint,jboolean,), 
        ATname,Bname,C,CT,rowfilter,colfilterAT,colfilterB,-1,-1,true)
    
    if ~isempty(CT)
        return AT.DB[C,CT]
    else
        return AT.DB[C]
    end

end

 # Helper function to convert Assoc fields to an Accumulo-friendly string
 function toDBstring(input)
    StringArray = Array{T} where T <: AbstractString
    NumericArray = Array{T} where T <: Number
    UnionArray = Array{T} where T <: Union{AbstractString,Number}
    
    if isa(input,StringArray)
        output = join(input,"\n")*"\n"
    elseif isa(input,NumericArray)
        output = join(string.(input),"\n")*"\n"
    elseif isa(input,UnionArray)
        output = join(convert(Array{AbstractString},input),"\n")*"\n"
    elseif isa(input,Colon)
        output = ":"
    elseif isa(input,StartsWith)
        str = input.inputString
        output = ""
        del = str[end]
        idx1 = 1
        idx2 = search(str,del,idx1+1)

        while idx2 > 0
            output = output*str[idx1:idx2]*":"*del*str[idx1:idx2-1]*Char(127)*del
            idx1 = idx2+1
            idx2 = search(str,del,idx2+1)
        end
    else
        output = input
    end
    
    return output
end

UnionArray = Array{Union{AbstractString,Number}}
ValidQueryTypes = Union{Colon,AbstractString,Array,UnionArray,StartsWith}

tablemult(AT::DBtableType,B::DBtableType,C::AbstractString,CT::AbstractString=""; rowfilter::ValidQueryTypes="",colfilterAT::ValidQueryTypes="",colfilterB::ValidQueryTypes="") = tablemult(AT,B,C,CT; rowfilter=toDBstring(rowfilter),colfilterAT=toDBstring(colfilterAT),colfilterB=toDBstring(colfilterB))