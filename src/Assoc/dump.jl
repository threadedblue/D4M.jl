#!/usr/bin/env julia

using D4M

dbinit()
DB = dbsetup("dbuno.conf")
@info "DB.instanceName=" * DB.instanceName
stem = "ccd"
Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T", 1000)    
T = Tccd[:,:]
for ()

    WriteCSV()
end