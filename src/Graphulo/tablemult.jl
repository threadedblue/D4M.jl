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
function tablemult(AT::DBtableType,B::DBtableType,C::AbstractString,CT=""; rowfilter="",colfilterAT="",colfilterB="")

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