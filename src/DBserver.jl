
# A DBserver struct contains the connect information for a database.
struct DBserver
    instanceName::String
    host::String
    user::String
    pass::String
    dbType::String
end

using JavaCall

# dbsetup calls the DBserver constructor given configuration information.
# When provided only the instance name, dbsetup assumes the default configuration directory.
#   The default location is that on the MIT Supercloud.
#   Assumes existance of two files: accumulo_user_password.txt and dnsname containing password and hostname, respectively.
#   Assumes username is AccumuloUser.
# When provided a directory, will assume configuration files are in that directory.
#   Assumes existance of two files: accumulo_user_password.txt and dnsname containing password and hostname, respectively.
#   Assumes username is AccumuloUser.
# When provided a configuration file, will read in and use the configuration in the file.
#   See example configuration file for formatting.

function dbinit()
    if ~JavaCall.isloaded()
        JavaCall.addClassPath(joinpath(dirname(pathof(D4M)),"..","libext","*"))
        JavaCall.addClassPath(joinpath(dirname(pathof(D4M)),"..","lib","graphulo-3.0.0.jar"))
        JavaCall.init()
    else
        println("JVM already initialized")

        # Check if correct packages are on classpath
        System = @jimport java.lang.System
        cpath = jcall(System, "getProperty", JString, (JString,), "java.class.path")

        if ~contains(cpath, "graphulo")
            println("Required libraries for database operations missing from Java classpath. Restart Julia and intialize jvm using dbinit().")
        end
    end
end

function dbsetup(instance, config="/home/gridsan/tools/groups/")
    # Note default value for config location is the MIT Supercloud default location
    if isdir(config) # Config dir
        dbdir = config*"/databases/"*instance
        f = open(dbdir*"/accumulo_user_password.txt","r")
        pword = readstring(f)
        f = open(dbdir*"/dnsname","r")
        hostname = replace(readstring(f),"\n","")*":2181"
        DB = DBserver(instance,hostname,"AccumuloUser",pword,"BigTableLike")
    else # Conifg file
        f = open(config)
        conf = readlines(config)
        conf = Dict(l[1] => l[2] for l in split.(conf,"="))

        DB = DBserver(conf["instance"],conf["hostname"],conf["username"],conf["password"],"BigTableLike")
    end
    if ~JavaCall.isloaded()
        println("Starting up JVM for DB operations")
        dbinit()
    end
    return DB
end
# ls returns a list of tables that exist in the DBserver DB.
function ls(DB::DBserver)
    dbInfo = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbInfo"
    dbInfoObj = dbInfo((JString, JString, JString, JString,), DB.instanceName, DB.host, DB.user, DB.pass)
    
    tables = jcall(dbInfoObj, "getTableList", JString, (),)
    
    return split(tables[1:end-1],tables[end])
end

# getindex returns a binding to a table. If the table does it exist, it creates the table.
# A database table struct is returned.
function getindex(DB::DBserver,tableName::String)
    
    ops = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbTableOperations"
    opsObj = ops((JString, JString, JString, JString,), DB.instanceName, DB.host, DB.user, DB.pass)
    
    if ~any(ls(DB) .== tableName) # Create new table if it doesn't exist
        println("Creating "*tableName*" in "*DB.instanceName);
        jcall(opsObj,"createTable", Nothing, (JString,), tableName)
    end
    
    d4mQuery = @jimport "edu.mit.ll.d4m.db.cloud.D4mDataSearch"
    queryObj = d4mQuery((JString, JString, JString, JString, JString,), DB.instanceName, DB.host, tableName, DB.user, DB.pass)
    
    return DBtable(DB, tableName, "", 0, 0, "", 5e5, queryObj,opsObj)
    
end

# getindex returns a binding to a table. If the table does it exist, it creates the table.
# When a second table name is provided, a database table pair is returned.
function getindex(DB::DBserver,tableName1::String,tableName2::String)
    
    ops = @jimport "edu.mit.ll.d4m.db.cloud.D4mDbTableOperations"
    opsObj = ops((JString, JString, JString, JString,), DB.instanceName, DB.host, DB.user, DB.pass)
    
    # Create new tables if they don't exist
    if ~any(ls(DB) .== tableName1) || ~any(ls(DB) .== tableName2)
        if ~any(ls(DB) .== tableName1)
            println("Creating "*tableName1*" in "*DB.instanceName);
            jcall(opsObj,"createTable", Nothing, (JString,), tableName1)
        end
        if ~any(ls(DB) .== tableName2)
            println("Creating "*tableName2*" in "*DB.instanceName);
            jcall(opsObj,"createTable", Nothing, (JString,), tableName2)
        end
    end
    
    d4mQuery = @jimport "edu.mit.ll.d4m.db.cloud.D4mDataSearch"
    queryObj = d4mQuery((JString, JString, JString, JString, JString,), DB.instanceName, DB.host, tableName1, DB.user, DB.pass)
    
    return DBtablePair(DB, tableName1, tableName2, "", 0, 0, "", 5e5, queryObj,opsObj)
    
end