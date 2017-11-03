#import Base.full
#=
triple : return A in triple String form
=#
function printTriple(A::Assoc)

    r,c,v = find(A)

    output = "(" .* string.(r) .* "," .* string.(c) .* ")\t".* string.(v)

    println.(output)

    return output
end