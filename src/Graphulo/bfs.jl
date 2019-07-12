using JavaCall

DBtableType = Union{DBtable,DBtablePair}

function makedegreetable(A::DBtableType, Rtable = ""::AbstractString, countColumns = true::Bool, colq = ""::AbstractString)
    # /**
    # * Create a degree table from an existing table.
    # * @param table Name of original table.
    # * @param Degtable Name of degree table. Created if it does not exist.
    # *                 Use a combiner if you want to sum in the new degree entries into an existing table.
    # * @param countColumns True means degrees are the <b>number of entries in each row</b>.
    # *                     False means degrees are the <b>sum or weights of entries in each row</b>.
    # * @param colq The name of the degree column in Degtable. Default is "".
    # * @return The number of rows in the original table.
    # */
    # public long generateDegreeTable(String table, String Degtable, boolean countColumns, String colq) 

    if isa(A, DBtablePair)
        Atable = A.name1
    else
        Atable = A.name
    end

    jcall(A.DB.Graphulo, "generateDegreeTable", jlong, 
        (JString, JString, jboolean, JString,), 
        Atable, Rtable, countColumns, colq)
end

function adjbfs(A::DBtableType, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, ADegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false::Bool)


#    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
#    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)

    if isa(A, DBtablePair)
        Atable = A.name1
    else
        Atable = A.name
    end

    jcall(A.DB.Graphulo, "AdjBFS", JString, 
        (JString, JString, jint, JString, JString, JString, JString, jboolean, jint, jint,), 
        Atable, v0, numsteps, Rtable, RtableTranspose, ADegtable, degColumn, degInColQ, minDegree, maxDegree)

end

function edgebfs(A::DBtableType, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, EDegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)


    #    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
    #    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)
    
    if isa(A, DBtablePair)
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
    MutableLong = @jimport "org.apache.commons.lang.mutable.MutableLong"
    
    jcall(A.DB.Graphulo, "EdgeBFS", JString, 
            (JString, JString, jint, JString, JString, 
                JString, JString, JString, JString, 
                jboolean, jint, jint, IteratorSetting, 
                jint, Authorizations, Authorizations, 
                JString, jboolean, jboolean, MutableLong,), 
            Etable, v0, numsteps, Rtable, RtableTranspose, 
            startPrefixes, endPrefixes, EDegtable, degColumn, 
            degInColQ, minDegree, maxDegree, plusOp, 
            EScanIteratorPriority, Eauthorizations, EDegauthorizations, 
            newVisibility, useNewTimestamp, outputUnion, numEntriesWritten)
    
end
    
function singlebfs(A::DBtableType, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, ADegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)


    #    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
    #    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)
    
    if isa(A, DBtablePair)
        Atable = A.name1
    else
        Atable = A.name
    end
    
    jcall(A.DB.Graphulo, "AdjBFS", JString, 
            (JString, JString, jint, JString, JString, JString, JString, jboolean, jint, jint,), 
            Atable, v0, numsteps, Rtable, RtableTranspose, ADegtable, degColumn, degInColQ, minDegree, maxDegree)
    
end 
