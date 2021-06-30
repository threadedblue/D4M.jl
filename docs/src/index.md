```@docs
getindex(A::Assoc, i::Array{Int64}, j::Array{Int64})

> : get a new Assoc where all of the elements of input Assoc matches the given Element.

< : get a new Assoc where all of the elements of input Assoc matches the given Element.

== : get a new Assoc where all of the elements of input Assoc matches the given Element.

diag(A::Assoc)

WriteCSV(A::Assoc, fname, del=',', eol='\n')

ReadCSV(fname,del=',',eol='\n'; quotes=true)
```