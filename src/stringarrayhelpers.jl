# This file contains helper functions for working with strings and string arrays in the context of D4M


# String manipulation helper functions useful for parsing
function SplitStr(s12, sep)
    # Given an array of strings, each of which has two substrings joined with a separator,
    # split the array into two arrays, one per substring.
    # Fix: split each element only once (previous version called split twice per element).
    splits = [split(x, sep) for x in s12]
    s1 = [s[1] for s in splits]
    s2 = [s[2] for s in splits]
    return s1, s2
end

function NumStr(stringA)
    # Returns the number of elements in a last-char-delimited string
    return length(split(stringA[1:end - 1], stringA[end]))
end

function CatStr(s1::Array, sep::AbstractString, s2::Array)
    # Element-wise concatenation of two arrays of strings, adding sep between each element.
    # Fix: single-pass zip avoids two intermediate arrays (was: s1 .* [sep] .* s2).
    return [a * sep * b for (a, b) in zip(s1, s2)]
end

# Operations used internally that gain performance benefit on sorted inputs

#=
StrUnique
Get the unique and sorted single-character-separated sequences of strings.
Also returns the mapping from the original ordering in the given sequence to the sorted version.

Returns: (uniqueSeq, Int[], forwardMapping)
The middle value (backwardMapping) is kept as an empty placeholder for API compatibility
but is no longer allocated (was previously zeros(1, n) — a dead allocation).
=#
function StrUnique(inputString::AbstractString, csv = false)
    separator = csv ? ',' : inputString[end]
    strA = split(inputString, separator)
    if !isempty(strA) && last(strA) == ""
        pop!(strA)
    end

    uniqueSeq = sort!(unique(strA))
    if !isempty(uniqueSeq) && uniqueSeq[1] == ""
        popfirst!(uniqueSeq)
    end

    forwardMapping = [searchsortedfirst(uniqueSeq, x) for x in strA]

    # backwardMapping was previously zeros(1, length(forwardMapping)) — allocated but
    # never read by any caller. Replaced with Int[] to eliminate the dead allocation.
    return uniqueSeq, Int[], forwardMapping
end

function searchsortedmapping(A::Array, B::Array)
    ## Assume A \in B
    ## For each element of A, return its index in B (merge-scan, O(|A|+|B|))
    AtoB = Array{Int64,1}()
    temp_index_A = 1
    temp_index_B = 1

    while (temp_index_A <= length(A))
        if A[temp_index_A] == B[temp_index_B]
            push!(AtoB, temp_index_B)
            temp_index_A += 1
            temp_index_B += 1
        else
            temp_index_B += 1
        end
    end

    return AtoB
end

function sortedintersect(A::Array, B::Array)
    ABintersect = typeof(A)()
    temp_index_A = 1
    temp_index_B = 1

    while (temp_index_A <= length(A)) & (temp_index_B <= length(B))
        if A[temp_index_A] == B[temp_index_B]
            push!(ABintersect, A[temp_index_A])
            temp_index_A += 1
            temp_index_B += 1
        elseif A[temp_index_A] < B[temp_index_B]
            temp_index_A += 1
        else
            temp_index_B += 1
        end
    end

    return ABintersect
end

function sortedintersectmapping(A::Array, B::Array)
    #Compute intersect of two sorted and unique arrays.
    #Return the mapping from each array to the intersect.
    temp_index_A = 1
    temp_index_B = 1
    Amap = Array{Int64,1}()
    Bmap = Array{Int64,1}()

    while (temp_index_A <= length(A)) & (temp_index_B <= length(B))
        if A[temp_index_A] == B[temp_index_B]
            push!(Amap, temp_index_A)
            push!(Bmap, temp_index_B)
            temp_index_A += 1
            temp_index_B += 1
        elseif A[temp_index_A] < B[temp_index_B]
            temp_index_A += 1
        else
            temp_index_B += 1
        end
    end

    return Amap, Bmap
end

function sortedunion(A::Array, B::Array)
    ABunion = typeof(A)()
    temp_index_A = 1
    temp_index_B = 1

    while (temp_index_A <= length(A)) || (temp_index_B <= length(B))
        if (temp_index_A > length(A))
            push!(ABunion, B[temp_index_B])
            temp_index_B += 1
        elseif (temp_index_B > length(B))
            push!(ABunion, A[temp_index_A])
            temp_index_A += 1
        elseif (A[temp_index_A] == B[temp_index_B])
            push!(ABunion, A[temp_index_A])
            temp_index_A += 1
            temp_index_B += 1
        elseif A[temp_index_A] < B[temp_index_B]
            push!(ABunion, A[temp_index_A])
            temp_index_A += 1
        else
            push!(ABunion, B[temp_index_B])
            temp_index_B += 1
        end
    end

    return ABunion
end

########################################################
# D4M: Dynamic Distributed Dimensional Data Model
# Architect: Dr. Jeremy Kepner (kepner@ll.mit.edu)
# Software Engineer: Alexander Chen (alexc89@mit.edu)
########################################################
