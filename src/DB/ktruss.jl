using JavaCall

function ktrussadj(A::DBtableType, Rtable::AbstractString, k::Number, filterRowCol::AbstractString, forceDelete::Bool; maxiter = 2^31 - 1::Number)
# /**
# * From input <b>unweighted, undirected</b> adjacency table Aorig, put the k-Truss
# * of Aorig in Rfinal.
# * @param Aorig Unweighted, undirected adjacency table.
# * @param Rfinal Does not have to previously exist. Writes the kTruss into Rfinal if it already exists.
# *               Use a combiner if you want to sum it in.
# * @param k Trivial if k <= 2.
# * @param filterRowCol Filter applied to rows and columns of Aorig
# *                     (must apply to both rows and cols because A is undirected Adjacency table).
# * @param forceDelete False means throws exception if the temporary tables used inside the algorithm already exist.
# *                    True means delete them if they exist.
# * @param Aauthorizations Authorizations for scanning Atable. Null means use default: Authorizations.EMPTY
# * @param RNewVisibility Visibility label for new entries created. Null means no visibility label.
# * @param maxiter A bound on the number of iterations. The algorithm will halt
# *                either at convergence or after reaching the maximum number of iterations.
# *                Note that if the algorithm stops before convergence, the result may not be correct.
# * @return nnz of the kTruss subgraph, which is 2* the number of edges in the kTruss subgraph.
# *          Returns -1 if k < 2 since there is no point in counting the number of edges.
# */
# public long kTrussAdj(String Aorig, String Rfinal, int k,
#                      String filterRowCol, boolean forceDelete,
#                      Authorizations Aauthorizations, String RNewVisibility,
#                      int maxiter) {

    if isa(A, DBtablePair)
        Atable = A.name1
    else
        Atable = A.name
    end

    JAuthorizations = @jimport "org.apache.accumulo.core.security.Authorizations"
    emptyAuth = JAuthorizations((), )
    newVisibility = ""

    result = jcall(DB.Graphulo,"kTrussAdj", jlong, 
        (JString, JString, jint, JString, jboolean, JAuthorizations, JString, jint), 
        Atable, Rtable, k, toDBstring(filterRowCol), forceDelete, emptyAuth, newVisibility, maxiter)

end

function ktrussedge(E::DBtableType, ET::DBtableType, Rtable::AbstractString, RTtable::AbstractString, k::Number, edgeFilter::AbstractString, forceDelete::Bool)
    # /**
    # * From input <b>unweighted, undirected</b> incidence table Eorig, put the k-Truss
    # * of Eorig in Rfinal.  Needs transpose ETorig, and can output transpose of k-Truss subgraph too.
    # * @param Eorig Unweighted, undirected incidence table.
    # * @param ETorig Transpose of input incidence table.
    # *               Optional.  Created on the fly if not given.
    # * @param Rfinal Does not have to previously exist. Writes the kTruss into Rfinal if it already exists.
    # *               Use a combiner if you want to sum it in.
    # * @param RTfinal Does not have to previously exist. Writes in the transpose of the kTruss subgraph.
    # * @param k Trivial if k <= 2.
    # * @param edgeFilter Filter on rows of Eorig, i.e., the edges in an incidence table.
    # * @param forceDelete False means throws exception if the temporary tables used inside the algorithm already exist.
    # *                    True means delete them if they exist.
    # * @param Eauthorizations Authorizations for scanning Atable. Null means use default: Authorizations.EMPTY
    # * @return  nnz of the kTruss subgraph, which is 2* the number of edges in the kTruss subgraph.
    # *          Returns -1 if k < 2 since there is no point in counting the number of edges.
    # *  public long kTrussEdge(String Eorig, String ETorig, String Rfinal, String RTfinal, int k,
    # String edgeFilter, boolean forceDelete, Authorizations Eauthorizations)

    if isa(E, DBtablePair)
        Etable = E.name1
    else
        Etable = E.name
    end

    if isa(ET, DBtablePair)
        ETtable = ET.name1
    else
        ETtable = ET.name
    end

    JAuthorizations = @jimport "org.apache.accumulo.core.security.Authorizations"
    emptyAuth = JAuthorizations((), )
    newVisibility = ""

    result = jcall(DB.Graphulo,"kTrussEdge", jlong, 
        (JString, JString, JString, JString, jint, JString, jboolean, JAuthorizations, JString, jint), 
        Etable, ETtable, Rtable, RTtable, k, toDBstring(edgeFilte), forceDelete, emptyAuth)

end