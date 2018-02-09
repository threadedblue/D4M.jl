
# DBtable contains the table binding information, as well as the
# d4mQuery Java object for the table.
struct DBtable
    DB::DBserver
    name::String
    security::String
    numLimit::Int
    numRow::Int
    columnfamily::String
    putBytes::Number
    d4mQuery
    tableOps
end

# DBtablePair contains the table pair binding information, as well as the
# d4mQuery Java object for the table.
# The DBtablePair contains bindings to both a table and its transpose.
struct DBtablePair
    DB::DBserver
    name1::String
    name2::String
    security::String
    numLimit::Int
    numRow::Int
    columnfamily::String
    putBytes::Number
    d4mQuery
    tableOps
end

# Deletes specified DB table
# TODO: add check whether want to delete
function delete(table::DBtable)
    jcall(table.tableOps,"deleteTable", Void, (JString,), table.name)
 end
 
 function delete(table::DBtablePair)
     jcall(table.tableOps,"deleteTable", Void, (JString,), table.name1)
     jcall(table.tableOps,"deleteTable", Void, (JString,), table.name2)
 end

 # Helper function to convert Assoc fields to an Accumulo-friendly string
 function toDBstring(input)
    StringArray = Array{T} where T <: AbstractString
    NumericArray = Array{T} where T <: Number
    UnionArray = Array{T} where T <: Union{AbstractString,Number}
    
    if isa(input,StringArray)
        output = join(input,"\n")*"\n"
    elseif isa(input,NumericArray)
        output = string.(input)
    elseif isa(input,UnionArray)
        output = convert(Array{AbstractString},input)
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

# Base getindex function- i and j are d4m formatted strings (delimitered)
DBtableType = Union{DBtable,DBtablePair}
function getindex(table::DBtableType,i::AbstractString,j::AbstractString)
    
    jcall(table.d4mQuery,"setCloudType", Void, (JString,), table.DB.dbType)
    jcall(table.d4mQuery,"setLimit", Void, (jint,), table.numLimit)
    jcall(table.d4mQuery,"reset", Void, (),)
    
    dbResultSet = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbResultSet"
    
    if i!=":" || j==":" || isa(table,DBtable)
        
        if isa(table,DBtablePair)
            jcall(table.d4mQuery,"setTableName", Void, (JString,), table.name1)
        end
        jcall(table.d4mQuery,"doMatlabQuery",dbResultSet,(JString,JString,JString,JString,),i,j,table.columnfamily,table.security)

        r = jcall(table.d4mQuery,"getRowReturnString", JString, (),)
        c = jcall(table.d4mQuery,"getColumnReturnString", JString, (),)
        
    else # Search transpose table if column query
        jcall(table.d4mQuery,"setTableName", Void, (JString,), table.name2)
        jcall(table.d4mQuery,"doMatlabQuery",dbResultSet,(JString,JString,JString,JString,),j,i,table.columnfamily,table.security)

        c = jcall(table.d4mQuery,"getRowReturnString", JString, (),)
        r = jcall(table.d4mQuery,"getColumnReturnString", JString, (),)
    end
    
    v = jcall(table.d4mQuery,"getValueReturnString", JString, (),)
    
    return deepCondense(Assoc(r,c,v))
    
end

UnionArray = Array{T} where T <: Union{AbstractString,Number}
ValidQueryTypes = Union{Colon,AbstractString,UnionArray,StartsWith}

getindex(table::DBtableType,i::ValidQueryTypes,j::ValidQueryTypes) = getindex(table,toDBstring(i),toDBstring(j))

# Query iterator functionality
function getiterator(table::DBtableType,nelements::Number)
    
    if isa(table,DBtablePair)
        Ti = DBtablePair(table.DB, table.name1, table.name2, table.security,
            table.numLimit, table.numRow, table.columnfamily, table.putBytes,
            table.d4mQuery,table.tableOps)
    else
        Ti = DBtable(table.DB, table.name, table.security,
            table.numLimit, table.numRow, table.columnfamily, table.putBytes,
            table.d4mQuery,table.tableOps)
    end
    
    return Ti
end

# The getindex function to get the next few elements for an iterator table object
function getindex(table::DBtableType)
    
    #T.d4mQuery.next();
    #dbResultSet = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbResultSet"
    jcall(table.d4mQuery,"next",Void,(),)
    
    # check if transpose table query- if so flip the r and c results.
    tablename = jcall(table.d4mQuery,"getTableName", JString, (),)
    
    if isa(table,DBtablePair) && tablename == table.name2
        c = jcall(table.d4mQuery,"getRowReturnString", JString, (),)
        r = jcall(table.d4mQuery,"getColumnReturnString", JString, (),)
    else
        r = jcall(table.d4mQuery,"getRowReturnString", JString, (),)
        c = jcall(table.d4mQuery,"getColumnReturnString", JString, (),)
    end
    
    v = jcall(table.d4mQuery,"getValueReturnString", JString, (),)
    
    return deepCondense(Assoc(r,c,v))
    
end

# Helper function for ingest
function searchall(str::String,c::Char)
    idx = search(str,c)
    allIdx = idx

    while idx < endof(str)
        idx = search(str,c,idx+1)
        allIdx = [allIdx idx]
    end

    return allIdx
end

# putTriple is the main db ingest function
DBtableType = Union{DBtable,DBtablePair}
function putTriple(table::DBtableType,r::AbstractString,c::AbstractString,v::AbstractString)
    
    # Find chunk size for ingest
    chunkBytes = table.putBytes
    rIdx = [0 searchall(r,r[end])]
    cIdx = [0 searchall(c,c[end])]
    vIdx = [0 searchall(v,v[end])]
    numTriples = NumStr(r);
    avgBytePerTriple = (length(r) + length(c) + length(v))/numTriples;
    chunkSize = min(max(1,round(Integer,chunkBytes/avgBytePerTriple)),numTriples);
    
    # In Matlab D4M this is inside the loop- do we need to make a new object each time?
    dbInsert = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbInsert"
    
    if isa(table,DBtablePair)
        insertObj = dbInsert((JString, JString, JString, JString, JString,), table.DB.instanceName, table.DB.host, table.name1, table.DB.user, table.DB.pass)
        insertObjT = dbInsert((JString, JString, JString, JString, JString,), table.DB.instanceName, table.DB.host, table.name2, table.DB.user, table.DB.pass)
    else
        insertObj = dbInsert((JString, JString, JString, JString, JString,), table.DB.instanceName, table.DB.host, table.name, table.DB.user, table.DB.pass)
    end
        
    # Insert each chunk
    for i in 1:chunkSize:numTriples
        iNext = min(i + chunkSize,numTriples+1);
        rr = r[(rIdx[i]+1):rIdx[iNext]];
        cc = c[(cIdx[i]+1):cIdx[iNext]];
        vv = v[(vIdx[i]+1):vIdx[iNext]];
        
        jcall(insertObj,"doProcessing",Void,(JString,JString,JString,JString,JString,),rr, cc, vv, table.columnfamily, table.security)
        
        # Insert transpose into transpose table if DBtablePair
        if isa(table,DBtablePair)
            jcall(insertObjT,"doProcessing",Void,(JString,JString,JString,JString,JString,),cc, rr, vv, table.columnfamily, table.security)
        end
    end
    
end

UnionArray = Array{T} where T <: Union{AbstractString,Number}
ValidType = Union{UnionArray,AbstractString}

putTriple(table::DBtableType,r::ValidType,c::ValidType,v::ValidType) = putTriple(table,toDBstring(r),toDBstring(c),toDBstring(v))

# The put function deconstructs A and calls putTriple
function put(table::DBtableType,A::Assoc)
    r,c,v = find(A)
    putTriple(table,r,c,v)
end

#addColCombiner: Adds combiners to specific column names.
# Inputs: T = database table object
    # colNames = string list of column names. If ':,' (default) then sets all columns to combining.
    # combineType = combiner name "min", "max", or "sum";
    #      IF D4M_API_JAVA.jar is installed on the Accumulo instance, you can
    #      specify "min_decimal", "max_decimal", or "sum_decimal"
    #      to obtain the ability to combine on decimals
function addColCombiner(table::DBtable,colNames=":,",combineType="sum")   
        jcall(table.tableOps,"designateCombiningColumns", Void, (JString, JString, JString, JString,), table.name, colNames, combineType, table.columnfamily)
end

# nnz returns the number of entries in specified table
function nnz(table::DBtableType)
    if isa(table,DBtablePair)
        tname = table.name1
    else
        tname = table.name
    end
    
    arrayList = @jimport "java.util.ArrayList"
    list = @jimport "java.util.List"
    
    tableList = arrayList((),)
    jcall(tableList,"add",jboolean,(JObject,),Tadj.name1)
    
    jcall(table.tableOps,"getNumberOfEntries",jlong,(list,),tableList)
end