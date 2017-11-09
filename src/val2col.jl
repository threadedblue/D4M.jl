function val2col(A::Assoc,splitSep)
    #val2col: Append associative array values to column keys; inverse of col2type. 
    #Associative array user function.
    #  Usage:
    #    AA = val2col(A,splitSep)
    #  Inputs:
    #    A = associative array with string column keys
    #    splitSep = single character separator
    # Outputs:
    #    A = associative array with string column keys and numeric values
    
      r, cType, cVal, = find(A);
      c = CatStr(cType,splitSep, cVal);
      return Assoc(r,c,1);
    end