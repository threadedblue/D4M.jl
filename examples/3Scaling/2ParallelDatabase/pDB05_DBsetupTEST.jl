# Set up database connections and bindings
# Add required jars to classpath and then start up java
#dbinit()

(@isdefined myname) || (myname="DB_Scale_") # SET LOCAL LABEL TO AVOID COLLISIONS.
DB = dbsetup("uno",joinpath(Base.source_dir(),"db.conf"))

Tadj = DB[myname*"Tadj",myname*"TadjT"];    # Create database table pair for holding adjacency matrix.
TadjDeg = DB[myname*"TadjDeg"];                    # Create database table for counting degree.

Tedge = DB[myname*"Tedge",myname*"TedgeT"]; # Create database table pair for holding incidense matrix.
TedgeDeg = DB[myname*"TedgeDeg"];                  # Create database table for counting degree.

delete(Tedge); delete(Tadj); delete(TedgeDeg); delete(TadjDeg); 

Tadj = DB[myname*"Tadj",myname*"TadjT"];    # Create database table pair for holding adjacency matrix.
TadjDeg = DB[myname*"TadjDeg"];                    # Create database table for counting degree.

Tedge = DB[myname*"Tedge",myname*"TedgeT"]; # Create database table pair for holding incidense matrix.
TedgeDeg = DB[myname*"TedgeDeg"];                  # Create database table for counting degree.

addColCombiner(TadjDeg,"OutDeg,InDeg,","sum");  # Set accumulator columns.
addColCombiner(TedgeDeg,"Degree,","sum");      # Set accumulator columns.