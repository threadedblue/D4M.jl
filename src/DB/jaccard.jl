using JavaCall

function jaccard(A::DBtableType, ADegtable = ""::AbstractString, Rtable = ""::AbstractString; filterRowCol::ValidQueryTypes="")

# Original Java docstring:
# /**
# * From input <b>unweighted, undirected</b> adjacency table Aorig,
# * put the Jaccard coefficients in the upper triangle of Rfinal.
# * @param Aorig Unweighted, undirected adjacency table.
# * @param ADeg Degree table name.
# * @param Rfinal Should not previously exist. Writes the Jaccard table into Rfinal,
# *               using a couple combiner-like iterators.
# * @param filterRowCol Filter applied to rows and columns of Aorig
# *                     (must apply to both rows and cols because A is undirected Adjacency table).
# * @param Aauthorizations Authorizations for scanning Atable. Null means use default: Authorizations.EMPTY
# * @param RNewVisibility Visibility label for new entries created in Rtable. Null means no visibility label.
# * @return number of partial products sent to Rtable during the Jaccard coefficient calculation
# */
# public long Jaccard(String Aorig, String ADeg, String Rfinal,
# String filterRowCol, Authorizations Aauthorizations, String RNewVisibility)

    JAuthorizations = @jimport "org.apache.accumulo.core.security.Authorizations"
    emptyauth = JAuthorizations(  (), )
    newVisibility = "" # TODO default or null

    if isa(A, DBtablePair)
        Aname = A.name1
    else
        Aname = A.name
    end
    DB = A.DB

    return jcall(DB.Graphulo,"Jaccard", jlong, 
        (JString,JString,JString,JString,JAuthorizations,JString,), 
        Aname,ADegtable,Rtable,toDBstring(filterRowCol),emptyauth, newVisibility)
    
    # Return a binding to the table???

end