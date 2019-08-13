using JavaCall

function ktruss()
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

end