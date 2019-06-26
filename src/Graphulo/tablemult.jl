using JavaCall
#=
tablemult : matrix multiply between two Accumulo tables.
=#

#= TableMult
Performs matrix multiply A * B of tables A and B
Inputs:
    AT: Should be the transpose of the matrix you want to multiply.
        If AT is a DBtablePair, the name1 will be taken to be AT. If you want name2 to be A, use AT = transpose(A)
    B: The second matrix you want to multiply
    C: String indicating the name of the resulting table. If this table already exists, then the product will be added to the table. (C += A * B)
Optional Input:
    CT: String indicating the name of transpose of result table, default empty string does not create transpose table
Key/Value Inputs:
    rowfilter: string, indicating which rows of AT and B to perform the multiply on, formatted like D4M query strings
    colfilterAT: string indicating which columns of AT to perform the multiply on, formatted like D4M query strings
    colfilterB: string indicating which columns of B to perform the multiply on, formatted like D4M query strings
    (rowfilter, colfilterAT, and colfilterB can be any valid query type, including a string array or StartsWith)
    noadd: When set to true, if the resulting table already exists, then deletes it before multiplying. Thus the product itself is stored in the table, and not added.
Ouptut:
Returns a binding to the new table (or table pair if transpose table is specified)
=#
function tablemult(AT::DBtableType,B::DBtableType,C::AbstractString,CT::AbstractString=""; rowfilter::ValidQueryTypes="",colfilterAT::ValidQueryTypes="",colfilterB::ValidQueryTypes="", noadd::Bool=false)

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

    # if noadd
        
    # end

    jcall(AT.DB.Graphulo,"TableMult", jlong, 
        (JString,JString,JString,JString,JString,JString,JString,jint,jint,jboolean,), 
        ATname,Bname,C,CT,toDBstring(rowfilter),toDBstring(colfilterAT),toDBstring(colfilterB),-1,-1,true)
    
    if ~isempty(CT)
        return AT.DB[C,CT]
    else
        return AT.DB[C]
    end

end

#tablemult(AT::DBtableType,B::DBtableType,C::AbstractString,CT::AbstractString=""; rowfilter::ValidQueryTypes=[],colfilterAT::ValidQueryTypes=[],colfilterB::ValidQueryTypes=[]) = tablemult(AT,B,C,CT; rowfilter=toDBstring(rowfilter),colfilterAT=toDBstring(colfilterAT),colfilterB=toDBstring(colfilterB))
