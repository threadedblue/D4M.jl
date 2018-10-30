import PyPlot.spy,PyPlot.xticks,PyPlot.yticks
function spy(A::Assoc)
   im = spy(convert(Array,getadj(logical(A))))
   X = getcol(A)
   Y = getrow(A)

   numIdx = 8
   
   if length(X) > numIdx
       xIdx = 0:convert(Int64,floor((length(X)-1)/numIdx)):length(X)-1
   else
       xIdx = 0:(length(X)-1)
   end
   if length(Y) > numIdx
       yIdx = 0:convert(Int64,floor((length(Y)-1)/numIdx)):length(Y)-1
   else
       yIdx = 0:(length(Y)-1)
   end
   xticks(xIdx, X[collect(xIdx) .+ 1],rotation="vertical")
   yticks(yIdx, Y[collect(yIdx) .+ 1])
   
   return im

end
