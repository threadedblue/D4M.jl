import JLD.readas
import JLD.writeas

#=
Assoc Serialized for saving
Note that saving would convert row and col types to number.
=#

# Delimiter for saving- using new line is safer than comma!
del = "\n"

# Change type to struct
type AssocSerial
    rowstr::AbstractString
    colstr::AbstractString
    valstr::AbstractString

    rownum::AbstractString
    colnum::AbstractString
    valnum::AbstractString
    
    A::AbstractSparseMatrix
end

function JLD.writeas(data::Assoc)
    #Get parts from the assoc
    row = Row(data)
    col = Col(data)
    val = Val(data)
    A   = Adj(data)

    #Split the mapping array into string and number arrays for storage
    rowindex = searchsortedfirst(row,AbstractString,lt=isa)
    colindex = searchsortedfirst(col,AbstractString,lt=isa)
    valindex = searchsortedfirst(val,AbstractString,lt=isa)
    #test if there are string elements in the array
    if (rowindex == 1)
        rowstr = ""
    else
        rowstr = join(row[1:(rowindex-1)],del);
    end

    if (colindex == 1)
        colstr = ""
    else
        colstr = join(col[1:(colindex-1)],del);
    end
    
    if (valindex == 1)
        valstr = ""
    else
        valstr = join(val[1:(valindex-1)],del);
    end
    
    #test if there are number elements in the array.  Note that by serialization all numbers will be converted to float.

    if (rowindex == size(row,1)+1)
        rownum = ""
    else
        rownum = join(row[rowindex:end],del);
    end

    if (colindex == size(col,1)+1)
        colnum = ""
    else
        colnum = join(col[colindex:end],del);
    end
    
    if (valindex == size(val,1)+1)
        valnum = ""
    else
        valnum = join(val[valindex:end],del);
    end


    #Reconstitute converted parts into Serialized

    return AssocSerial(rowstr,colstr,valstr,rownum,colnum,valnum,A)
end

function JLD.readas(serData::AssocSerial)
    row = []
    if serData.rowstr != ""
       row = vcat(row, split(serData.rowstr,del)) ;
    end
    if serData.rownum != ""
        row = vcat(row, map(float,split(serData.rownum,del)));
    end
    row = Array{Union{AbstractString,Number}}(row)

    col = []
    if serData.colstr != ""
       col = vcat(col, split(serData.colstr,del)) ;
    end
    if serData.colnum != ""
        col = vcat(col, map(float,split(serData.colnum,del)));
    end
    col = Array{Union{AbstractString,Number}}(col)
    
    val = []
    if serData.valstr != ""
       val = vcat(val, split(serData.valstr,del)) ;
    end
    if serData.valnum != ""
        val = vcat(val, map(float,split(serData.valnum,del)));
    end
    val = Array{Union{AbstractString,Number}}(val)
    
    return Assoc(row,col,val,serData.A)
end
