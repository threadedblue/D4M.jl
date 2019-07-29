using JavaCall

function nmf(A::D4M.DBtable, AT::D4M.DBtable, k::Number, Wtable::AbstractString, WTtable ::AbstractString, Htable::AbstractString, HTtable::AbstractString, maxiter::Number, forceDelete::Bool, cutoffThreshold::Number, maxColsPerTopic::Number)

# Original Java docstring:
# /**
# * Non-negative matrix factorization.
# * The main NMF loop stops when either (1) we reach the maximum number of iterations or
# *    (2) when the absolute difference in error between A and W*H is less than 0.01 from one iteration to the next.
# *
# *
# * @param Aorig Accumulo input table to factor
# * @param ATorig Transpose of Accumulo input table to factor
# * @param Wfinal Output table W. Must not exist before this method.
# * @param WTfinal Transpose of output table W. Must not exist before this method.
# * @param Hfinal Output table H. Must not exist before this method.
# * @param HTfinal Transpose of output table H. Must not exist before this method.
# * @param K Number of topics.
# * @param maxiter Maximum number of iterations
# * @param forceDelete Forcibly delete temporary tables used if they happen to exist. If false, throws an exception if they exist.
# * @param cutoffThreshold Set entries of W and H below this threshold to zero. Default 0.
# * @param maxColsPerTopic Only retain the top X columns for each topic in matrix H. If <= 0, this is disabled.
# * @return The absolute difference in error (between A and W*H) from the last iteration to the second-to-last.
# */
# public double NMF(String Aorig, String ATorig,
#                  String Wfinal, String WTfinal, String Hfinal, String HTfinal,
#                  final int K, final int maxiter,
#                  boolean forceDelete, double cutoffThreshold, int maxColsPerTopic) 

    if isa(A, D4M.DBtablePair)
        Aname = A.name1
    else
        Aname = A.name
    end

    if isa(AT, D4M.DBtablePair)
        ATname = AT.name1
    else
        ATname = AT.name
    end

    DB = A.DB

    return jcall(DB.Graphulo,"NMF", jdouble, 
        (JString,JString,JString,JString,JString,JString,jint,jint,jboolean,jdouble,jint,), 
        Aname, ATname, Wtable, WTtable, Htable, HTtable, k, maxiter, forceDelete, cutoffThreshold, maxColsPerTopic)

end