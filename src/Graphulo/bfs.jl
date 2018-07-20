using JavaCall

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

function adjbfs(A::DBtableType,v0::AbstractString,numsteps::Number,Rtable=""::AbstractString,RtableTranspose=""::AbstractString,minDegree=0::Number,maxDegree=2^31-1::Number,ADegtable=""::AbstractString,degColumn=""::AbstractString,degInColQ=false)


#    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
#    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)

if isa(A,DBtablePair)
    Atable = A.name1
else
    Atable = A.name
end

jcall(A.DB.Graphulo,"AdjBFS", JString, 
        (JString,JString,jint,JString,JString,JString,JString,jboolean,jint,jint,), 
        Atable,v0,numsteps,Rtable,RtableTranspose,ADegtable,degColumn,degInColQ,minDegree,maxDegree)

end

function edgebfs(A::DBtableType,v0::AbstractString,numsteps::Number,Rtable=""::AbstractString,RtableTranspose=""::AbstractString,minDegree=0::Number,maxDegree=2^31-1::Number,EDegtable=""::AbstractString,degColumn=""::AbstractString,degInColQ=false)


    #    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
    #    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)
    
    if isa(A,DBtablePair)
        Etable = A.name1
    else
        Etable = A.name
    end
    


    startPrefixes = ","
    endPrefixes = ","
    plusOp = []
    EScanIteratorPriority = -1
    Eauthorizations = []
    EDegauthorizations = []
    newVisibility = []
    useNewTimestamp = true
    outputUnion = true
    numEntriesWritten = []

    #=
    JString, JString, jint, JString, JString, JString, JString, JString, JString, jboolean, jint, jint, IteratorSetting, jint,
    Authorizations, Authorizations, JString, jboolean, jboolean, MutableLong

    Etable, v0, k, Rtable, RTtable, startPrefixes, endPrefixes, ETDegtable, degColumn, degInColQ, minDegree, 
    maxDegree, plusOp, EScanIteratorPriority, Eauthorizations, EDegauthorizations, newVisibility, useNewTimestamp, outputUnion, numEntriesWritten
    =#
    
    Authorizations = @jimport "org.apache.accumulo.core.security.Authorizations"
    IteratorSetting = @jimport "org.apache.accumulo.core.client.IteratorSetting"
    MutableLong = @import "org.apache.commons.lang.mutable.MutableLong"
    
    jcall(A.DB.Graphulo,"EdgeBFS", JString, 
            (JString, JString, jint, JString, JString, 
                JString, JString, JString, JString, 
                jboolean, jint, jint, IteratorSetting, 
                jint, Authorizations, Authorizations, 
                JString, jboolean, jboolean, MutableLong,), 
            Etable, v0, k, Rtable, RtableTranspose, 
            startPrefixes, endPrefixes, EDegtable, degColumn, 
            degInColQ, minDegree, maxDegree, plusOp, 
            EScanIteratorPriority, Eauthorizations, EDegauthorizations, 
            newVisibility, useNewTimestamp, outputUnion, numEntriesWritten)
    
end
    
function singlebfs(A::DBtableType,v0::AbstractString,numsteps::Number,Rtable=""::AbstractString,RtableTranspose=""::AbstractString,minDegree=0::Number,maxDegree=2^31-1::Number,ADegtable=""::AbstractString,degColumn=""::AbstractString,degInColQ=false)


    #    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
    #    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)
    
    if isa(A,DBtablePair)
        Atable = A.name1
    else
        Atable = A.name
    end
    
    jcall(A.DB.Graphulo,"AdjBFS", JString, 
            (JString,JString,jint,JString,JString,JString,JString,jboolean,jint,jint,), 
            Atable,v0,numsteps,Rtable,RtableTranspose,ADegtable,degColumn,degInColQ,minDegree,maxDegree)
    
end 
