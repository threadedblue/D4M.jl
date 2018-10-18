
#=
Protected Accessor Function for User.
=#
function adj(A::Assoc)
    return copy(A.A)
end

function col(A::Assoc)
    if isempty(A)
        return Union{AbstractString, Number}[]
    else
        if isa(A.col[1], AbstractString) || ~(size(A.A,2) == A.col[end])
            return copy(A.col)
        end
        return 1:size(A.A,2)
    end
end

function row(A::Assoc)
    if isempty(A)
        return Union{AbstractString, Number}[]
    else
        if isa(A.row[1], AbstractString) || ~(size(A.A,1) == A.row[end])
            return copy(A.row)
        end
        return 1:size(A.A,1)
    end
end

function val(A::Assoc)
    if isempty(A)
        return Union{AbstractString, Number}[]
    else
        if isa(A.val[1], AbstractString)
            return copy(A.val)
        end
        return sort(unique(nonzeros(A.A)))
    end
end

