#import Base.*
using JavaCall
#=
* : matrix multiply between two Accumulo tables.
=#
DBtableType = Union{DBtable,DBtablePair}

#= Basic TableMult- no filtering
Multiplies tables A and B
Inputs:
A: Should be the transpose of the matrix you want to multiply.
    If A is a DBtablePair, the name1 will be taken to be A. If you want name2 to be A, use transpose(A)
B: The second matrix you want to multiply
C: String indicating the name of your new table.
Optional Inputs:

Ouptut:
Returns a binding to the new table
=#
function tablemult(A::DBtableType,B::DBtableType,C::AbstractString,CT=""; rowfilter="",colfilterA="",colfilterB="")

    if isa(A,DBtablePair)
        Aname = A.name1
    else
        Aname = A.name
    end

    if isa(B,DBtablePair)
        Bname = B.name1
    else
        Bname = B.name
    end

    #jcall(A.DB.Graphulo,"TableMult", jlong, (JString,JString,JString,JString,JString,JString,), Aname,Bname,C,rowfilter,colfilterA,colfilterB)
    #TableMult(String ATtable, String Btable, String Ctable)

    jcall(A.DB.Graphulo,"TableMult", jlong, 
        (JString,JString,JString,JString,JString,JString,JString,jint,jint,jboolean,), 
        Aname,Bname,C,CT,rowfilter,colfilterA,colfilterB,-1,-1,true)
    
    if ~isempty(CT)
        return A.DB[C,CT]
    else
        return A.DB[C]
    end

end