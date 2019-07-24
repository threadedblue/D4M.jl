using JavaCall

function makedegreetable(A::DBtableType, Rname = ""::AbstractString, countColumns = true::Bool, colq = ""::AbstractString)
    # /**
    # * Create a degree table from an existing table.
    # * @param table Name of original table.
    # * @param Degtable Name of degree table. Created if it does not exist.
    # *                 Use a combiner if you want to sum in the new degree entries into an existing table.
    # * @param countColumns True means degrees are the <b>number of entries in each row</b>.
    # *                     False means degrees are the <b>sum or weights of entries in each row</b>.
    # * @param colq The name of the degree column in Degtable. Default is "".

    # Returns a database table struct.

    # public long generateDegreeTable(String table, String Degtable, boolean countColumns, String colq) 

    if isa(A, DBtablePair)
        Aname = A.name1
    else
        Aname = A.name
    end

    jcall(A.DB.Graphulo, "generateDegreeTable", jlong, 
        (JString, JString, jboolean, JString,), 
        Aname, Rname, countColumns, colq)


    DB = A.DB
    ops = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbTableOperations"
    opsObj = ops((JString, JString, JString, JString,), DB.instanceName, DB.host, DB.user, DB.pass)
    d4mQuery = @jimport "edu.mit.ll.d4m.db.cloud.D4mDataSearch"
    queryObj = d4mQuery((JString, JString, JString, JString, JString,), DB.instanceName, DB.host, Rname, DB.user, DB.pass)
    
    return DBtable(DB, Rname, "", 0, 0, "", 5e5, queryObj,opsObj)
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

# Rows are edges, columns are nodes
function edgebfs(A::DBtableType, v0::AbstractString, numsteps::Number, Rtable = ""::AbstractString, RtableTranspose = ""::AbstractString, minDegree = 0::Number, maxDegree = 2^31 - 1::Number, EDegtable = ""::AbstractString, degColumn = ""::AbstractString, degInColQ = false)


    #    (String Atable, String v0, int k, String Rtable, String RtableTranspose,
    #    String ADegtable, String degColumn, boolean degInColQ, int minDegree, int maxDegree)
    
    if isa(A, DBtablePair)
        Etable = A.name1
    else
        Etable = A.name
    end
    
    JAuthorizations = @jimport "org.apache.accumulo.core.security.Authorizations"
    emptyAuth = JAuthorizations((), )
    JIteratorSetting = @jimport "org.apache.accumulo.core.client.IteratorSetting"
    emptyIteratorSetting = JIteratorSetting((jint, JString, JString), 500, "c", "cname")
    # We want to pass a null IteratorSetting as an argument; JavaCall hates this
    # here's a workaround: 
    emptyIteratorSetting.ptr = C_NULL
    JMutableLong = @jimport "org.apache.commons.lang.mutable.MutableLong"
    emptyMutableLong = JMutableLong((), )

    startPrefixes = ","
    endPrefixes = ","
    plusOp = emptyIteratorSetting
    EScanIteratorPriority = -1
    Eauthorizations = emptyAuth
    EDegauthorizations = emptyAuth
    newVisibility = "" # TODO use null or empty string as default?
    useNewTimestamp = true
    outputUnion = true
    numEntriesWritten = emptyMutableLong

    #=
    JString, JString, jint, JString, JString, JString, JString, JString, JString, jboolean, jint, jint, IteratorSetting, jint,
    Authorizations, Authorizations, JString, jboolean, jboolean, MutableLong

    Etable, v0, k, Rtable, RTtable, startPrefixes, endPrefixes, ETDegtable, degColumn, degInColQ, minDegree, 
    maxDegree, plusOp, EScanIteratorPriority, Eauthorizations, EDegauthorizations, newVisibility, useNewTimestamp, outputUnion, numEntriesWritten
    =#
    
    jcall(A.DB.Graphulo, "EdgeBFS", JString, 
            (JString, JString, jint, JString, JString, 
                JString, JString, JString, JString, 
                jboolean, jint, jint, JIteratorSetting, 
                jint, JAuthorizations, JAuthorizations, 
                JString, jboolean, jboolean, JMutableLong,), 
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
