# When run directly from the IDE (not via Pkg.test()), D4M won't be on the load path.
# Detect this by checking whether D4M is findable; if not, add the parent to LOAD_PATH.
# Pkg.test() already puts D4M in the temp project, so identify_package returns non-nothing.
if isnothing(Base.identify_package("D4M"))
    pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))
end

using Test
using D4M
using SparseArrays
using LinearAlgebra

# Helpers not in the public export list
const StrUnique             = D4M.StrUnique
const sortedintersect       = D4M.sortedintersect
const sortedintersectmapping = D4M.sortedintersectmapping
const sortedunion           = D4M.sortedunion
const searchsortedmapping   = D4M.searchsortedmapping
const condense              = D4M.condense
const deepCondense          = D4M.deepCondense
const emptyAssoc            = D4M.emptyAssoc

# Helper: sort triplets lexicographically for order-independent comparison.
function sorted_triples(r, c, v)
    triples = collect(zip(string.(r), string.(c), string.(v)))
    sort!(triples)
    return triples
end

@testset "D4M.jl" begin

    # ── String helpers ──────────────────────────────────────────────────────────

    @testset "StrUnique" begin
        u, _, fwd = StrUnique("c,b,a,")
        @test u == ["a","b","c"]
        @test fwd == [3,2,1]          # indices of ["c","b","a"] in sorted ["a","b","c"]

        # Trailing delimiter is consumed; no trailing empty element
        @test length(u) == 3

        # Duplicate removal
        u2, _, _ = StrUnique("x,x,y,")
        @test u2 == ["x","y"]
    end

    @testset "SplitStr" begin
        s1, s2 = SplitStr(["c1|v1","c2|v2"], "|")
        @test s1 == ["c1","c2"]
        @test s2 == ["v1","v2"]
    end

    @testset "CatStr" begin
        out = CatStr(["c1","c2"], "|", ["v1","v2"])
        @test out == ["c1|v1","c2|v2"]
    end

    @testset "sortedunion" begin
        @test sortedunion(["a","c"], ["b","c","d"]) == ["a","b","c","d"]
        @test sortedunion(String[], ["a"]) == ["a"]
        @test sortedunion(["a"], String[]) == ["a"]
    end

    @testset "sortedintersect" begin
        @test sortedintersect(["a","b","c"], ["b","c","d"]) == ["b","c"]
        @test sortedintersect(["a"], ["b"]) == String[]
    end

    @testset "sortedintersectmapping" begin
        Amap, Bmap = sortedintersectmapping(["b","c"], ["a","b","c","d"])
        @test Amap == [1,2]   # positions in ["b","c"]
        @test Bmap == [2,3]   # positions in ["a","b","c","d"]
    end

    @testset "searchsortedmapping" begin
        # A ⊆ B; return index of each A element in B
        idx = searchsortedmapping(["b","c"], ["a","b","c","d"])
        @test idx == [2,3]
    end

    # ── Assoc constructor ───────────────────────────────────────────────────────

    @testset "Constructor – D4M strings" begin
        A = Assoc("r1,r2,", "c1,c2,", "v1,v2,")
        @test collect(getrow(A)) == ["r1","r2"]
        @test collect(getcol(A)) == ["c1","c2"]
        @test collect(getval(A)) == ["v1","v2"]
        @test size(A) == (2,2)
        @test nnz(A) == 2
    end

    @testset "Constructor – arrays of strings" begin
        A = Assoc(["r1","r1","r2"], ["c1","c2","c1"], ["v1","v2","v3"])
        @test collect(getrow(A)) == ["r1","r2"]
        @test collect(getcol(A)) == ["c1","c2"]
        @test Set(getval(A)) == Set(["v1","v2","v3"])
        @test nnz(A) == 3
    end

    @testset "Constructor – numeric values (val sentinel)" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [10.0, 20.0])
        @test A.val == [1.0]          # numeric sentinel
        r, c, v = find(A)
        @test Set(zip(string.(r), string.(c))) == Set([("r1","c1"),("r2","c2")])
        @test Set(v) == Set([10.0, 20.0])
    end

    @testset "Constructor – scalar broadcast" begin
        A = Assoc(["r1","r2"], ["c1","c2"], 1.0)
        @test nnz(A) == 2
        _, _, v = find(A)
        @test all(v .== 1.0)
    end

    @testset "Constructor – empty" begin
        A = emptyAssoc()
        @test isempty(A)
        @test nnz(A) == 0
    end

    # ── Accessors ───────────────────────────────────────────────────────────────

    @testset "Accessors" begin
        A = Assoc(["r1","r1","r2"], ["c1","c2","c2"], ["va","vb","vc"])

        @test size(A) == (2,2)
        @test nnz(A) == 3
        @test !isempty(A)

        r, c, v = find(A)
        @test length(r) == 3
        @test all(r .∈ Ref(["r1","r2"]))
        @test all(c .∈ Ref(["c1","c2"]))
        @test all(v .∈ Ref(["va","vb","vc"]))

        @test collect(getrow(A)) == ["r1","r2"]
        @test collect(getcol(A)) == ["c1","c2"]
        @test sort(collect(getval(A))) == ["va","vb","vc"]
        @test getadj(A) isa SparseMatrixCSC
    end

    # ── Indexing ────────────────────────────────────────────────────────────────

    @testset "Indexing – integer" begin
        A = Assoc(["r1","r2","r3"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A[1, :]
        @test collect(getrow(B)) == ["r1"]
        @test nnz(B) == 1
    end

    @testset "Indexing – range" begin
        A = Assoc(["r1","r2","r3"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A[1:2, :]
        @test size(B)[1] == 2
        @test collect(getrow(B)) == ["r1","r2"]
    end

    @testset "Indexing – Colon" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [1.0, 2.0])
        @test nnz(A[:,:]) == nnz(A)
        # A is diagonal: col 1 only has r1; condense removes r2 → result is 1×1
        @test size(A[:,1]) == (1,1)
        @test nnz(A[:,1]) == 1
    end

    @testset "Indexing – D4M string selector" begin
        A = Assoc(
            ["r1","r2","r3","r3"],
            ["c1","c2","c3","c1"],
            [1.0, 2.0, 3.0, 4.0]
        )
        B = A["r1,r3,", :]
        @test sort(collect(getrow(B))) == ["r1","r3"]
        @test nnz(B) == 3          # r1@c1, r3@c3, r3@c1
    end

    @testset "Indexing – Vector{String} (regression)" begin
        # Vector{String} is not a subtype of Array{Union{AbstractString,Number}};
        # dispatch overloads added explicitly in getindex.jl.
        A = Assoc(["alice","bob","carol"], ["age","score","dept"],
                  [25.0, 80.0, 30.0])
        sel = ["alice","carol"]     # plain Vector{String}
        B = A[sel, :]
        @test sort(collect(getrow(B))) == ["alice","carol"]
        @test nnz(B) == 2
    end

    @testset "Indexing – Regex" begin
        A = Assoc(["alice","bob","carol"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A[r"^b", :]
        @test collect(getrow(B)) == ["bob"]
        @test nnz(B) == 1
    end

    @testset "Indexing – StartsWith" begin
        A = Assoc(["alice","bob","carol"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A[StartsWith("ca"), :]
        @test collect(getrow(B)) == ["carol"]
        C = A[StartsWith("al,bo,"), :]   # D4M-style multi-prefix
        @test sort(collect(getrow(C))) == ["alice","bob"]
    end

    # ── Comparisons ─────────────────────────────────────────────────────────────

    @testset "Comparisons – numeric" begin
        A = Assoc(["r1","r2","r3"], ["c1","c2","c3"], [1.0, 5.0, 10.0])

        gt = A > 4.0
        @test nnz(gt) == 2     # 5.0 and 10.0

        lt = A < 5.0
        @test nnz(lt) == 1     # only 1.0

        eq = A == 5.0
        @test nnz(eq) == 1
        _, _, v_eq = find(eq)
        @test v_eq[1] ≈ 5.0

        b = bounded(A, 1.0, 5.0)
        @test nnz(b) == 2      # 1.0 and 5.0

        sb = strictbounded(A, 1.0, 5.0)
        @test nnz(sb) == 0     # strict: neither 1.0 nor 5.0 included
    end

    @testset "Comparisons – string-valued" begin
        A = Assoc(["r1","r2","r3"], ["c1","c2","c3"], ["a","b","c"])

        gt = A > "b"
        @test nnz(gt) == 1     # "c" > "b"

        lt = A < "b"
        @test nnz(lt) == 1     # "a" < "b"

        eq = A == "b"
        @test nnz(eq) == 1
    end

    # ── Arithmetic ──────────────────────────────────────────────────────────────

    @testset "plus – numeric + numeric (disjoint)" begin
        A = Assoc(["r1"], ["c1"], [3.0])
        B = Assoc(["r2"], ["c2"], [4.0])
        C = A + B
        @test nnz(C) == 2
        r, c, v = find(C)
        @test Set(zip(string.(r),string.(c))) == Set([("r1","c1"),("r2","c2")])
    end

    @testset "plus – numeric + numeric (overlap)" begin
        A = Assoc(["r1"], ["c1"], [3.0])
        B = Assoc(["r1"], ["c1"], [4.0])
        C = A + B
        @test nnz(C) == 1
        _, _, v = find(C)
        @test v[1] ≈ 7.0
    end

    @testset "plus – string + string" begin
        A = Assoc(["r1","r2"], ["c1","c2"], ["va","vb"])
        B = Assoc(["r2","r3"], ["c2","c3"], ["vc","vd"])
        C = A + B
        @test nnz(C) == 3
    end

    @testset "plus – bug-fix: numeric A + string B" begin
        # Before the fix, plus checked A.val twice instead of A.val then B.val.
        # When A is numeric (val==[1.0]) and B is string-valued with indices > 1,
        # B's string indices were cast directly to Float64 rather than being
        # logicalized to 1.0. This tests that B is correctly logicalized.
        A = Assoc(["r1"],["c1"],[1.0])                         # numeric
        B = Assoc(["r2","r3"],["c2","c3"],["va","vb"])         # string; "vb" → index 2
        C = A + B
        _, _, v = find(C)
        @test all(v .≈ 1.0)    # bug gives 2.0 for the "vb" cell
    end

    @testset "minus" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [3.0, 5.0])
        B = Assoc(["r1","r2"], ["c1","c2"], [1.0, 2.0])
        C = A - B
        @test nnz(C) == 2
        _, _, v = find(C)
        @test Set(v) == Set([2.0, 3.0])
    end

    @testset "multiply" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [2.0, 3.0])
        B = Assoc(["c1","c2"], ["d1","d2"], [4.0, 5.0])
        C = A * B
        @test sort(collect(getrow(C))) == ["r1","r2"]
        @test sort(collect(getcol(C))) == ["d1","d2"]
        r, c, v = find(C)
        triple_set = Set(zip(string.(r), string.(c), v))
        @test ("r1","d1",8.0) ∈ triple_set
        @test ("r2","d2",15.0) ∈ triple_set
    end

    @testset "and (&)" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [1.0, 2.0])
        B = Assoc(["r2","r3"], ["c2","c3"], [3.0, 4.0])
        C = A & B
        @test collect(getrow(C)) == ["r2"]
        @test collect(getcol(C)) == ["c2"]
        @test nnz(C) == 1
    end

    # ── Conversion ──────────────────────────────────────────────────────────────

    @testset "val2col" begin
        A = Assoc(["r1","r1","r2"], ["c1","c2","c1"], ["v1","v2","v3"])
        B = val2col(A)
        @test B.val == [1.0]        # result is numeric
        cols_B = sort(collect(getcol(B)))
        # All combined keys must be present
        @test "c1|v1" ∈ cols_B || "c1|v3" ∈ cols_B   # at least one c1-origin col
        @test any(startswith(s, "c2") for s in cols_B)
        @test nnz(B) == 3
    end

    @testset "col2type" begin
        A = Assoc(["r1","r1","r2"], ["c1","c2","c1"], ["v1","v2","v3"])
        B = val2col(A)
        C = col2type(B)
        r_A, c_A, v_A = find(A)
        r_C, c_C, v_C = find(C)
        @test sorted_triples(r_A, c_A, v_A) == sorted_triples(r_C, c_C, v_C)
    end

    @testset "val2col – default separator" begin
        A = Assoc(["r1"], ["c1"], ["v1"])
        B1 = val2col(A)          # default "|"
        B2 = val2col(A, "|")
        r1,c1,_ = find(B1)
        r2,c2,_ = find(B2)
        @test c1 == c2           # same result with explicit default
    end

    # ── Structural ──────────────────────────────────────────────────────────────

    @testset "condense – removes empty rows and cols" begin
        # Build a 3×3 Assoc with entries only at (r1,c1) and (r3,c3);
        # r2 and c2 are empty and should be condensed away.
        rows = Array{Union{AbstractString,Number}}(["r1","r2","r3"])
        cols = Array{Union{AbstractString,Number}}(["c1","c2","c3"])
        vals = Array{Union{AbstractString,Number}}([1.0])
        M    = sparse([1,3],[1,3],[1.0,2.0],3,3)
        A    = Assoc(rows, cols, vals, M)
        B    = condense(A)
        @test size(B) == (2,2)
        @test collect(getrow(B)) == ["r1","r3"]
        @test collect(getcol(B)) == ["c1","c3"]
        @test nnz(B) == 2
    end

    @testset "deepCondense – removes unused val entries" begin
        rows = Array{Union{AbstractString,Number}}(["r1","r2"])
        cols = Array{Union{AbstractString,Number}}(["c1","c2"])
        vals = Array{Union{AbstractString,Number}}(["va","vb","vc"])
        # Entries use val indices 1 and 3 ("va" and "vc"); "vb" (index 2) unused
        M    = sparse([1,2],[1,2],[1,3],2,2)
        A    = Assoc(rows, cols, vals, M)
        B    = deepCondense(A)
        @test sort(collect(getval(B))) == ["va","vc"]    # "vb" dropped
    end

    @testset "logical" begin
        A = Assoc(["r1","r2"], ["c1","c2"], ["x","y"])
        L = logical(A)
        @test L.val == [1.0]
        _, _, v = find(L)
        @test all(v .== 1.0)
        @test nnz(L) == nnz(A)
    end

    @testset "str2num" begin
        A = Assoc("r1,r2,", "c1,c2,", "10,20,")
        B = str2num(A)
        @test B.val == [1.0]       # numeric Assoc
        _, _, v = find(B)
        @test Set(v) == Set([10, 20])
    end

    # ── Operations ──────────────────────────────────────────────────────────────

    @testset "transpose – materializes SparseMatrixCSC" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [1.0, 2.0])
        AT = transpose(A)
        @test AT.A isa SparseMatrixCSC          # not a lazy Transpose wrapper
        @test collect(getrow(AT)) == ["c1","c2"]
        @test collect(getcol(AT)) == ["r1","r2"]
        @test nnz(AT) == nnz(A)
    end

    @testset "abs – numeric" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [-3.0, 4.0])
        B = D4M.abs(A)
        _, _, v = find(B)
        @test all(v .>= 0)
        @test Set(v) == Set([3.0, 4.0])
    end

    @testset "abs – string-valued raises" begin
        A = Assoc("r1,", "c1,", "v1,")
        @test_throws ErrorException D4M.abs(A)
    end

    @testset "sqIn – A'*A, cols become both axes" begin
        A = Assoc(
            ["r1","r1","r2"],
            ["c1","c2","c1"],
            [1.0, 2.0, 3.0]
        )
        B = sqIn(A)
        @test B.A isa SparseMatrixCSC           # materialized
        @test sort(collect(getrow(B))) == ["c1","c2"]
        @test sort(collect(getcol(B))) == ["c1","c2"]
        r, c, v = find(B)
        # (c1,c1) entry: A[:,c1]'*A[:,c1] = 1²+3² = 10
        idx = findfirst(i -> r[i]=="c1" && c[i]=="c1", 1:length(r))
        @test v[idx] ≈ 10.0
    end

    @testset "sqOut – A*A', rows become both axes" begin
        A = Assoc(
            ["r1","r1","r2"],
            ["c1","c2","c1"],
            [1.0, 2.0, 3.0]
        )
        B = sqOut(A)
        @test B.A isa SparseMatrixCSC
        @test sort(collect(getrow(B))) == ["r1","r2"]
        @test sort(collect(getcol(B))) == ["r1","r2"]
    end

    # ── Properties ──────────────────────────────────────────────────────────────

    @testset "size / nnz / isempty" begin
        A = Assoc(
            ["r1","r1","r2","r2","r2"],
            ["c1","c2","c1","c2","c3"],
            ["a","b","c","d","e"]
        )
        @test size(A) == (2,3)
        @test nnz(A) == 5
        @test !isempty(A)
        @test isempty(emptyAssoc())
    end

    # ── Structural helpers ───────────────────────────────────────────────────────

    @testset "norow / nocol" begin
        A = Assoc(["r1","r2"], ["c1","c2"], [1.0, 2.0])
        B = norow(A)
        @test all(isa.(getrow(B), Number))   # row keys replaced by numbers
        C = nocol(A)
        @test all(isa.(getcol(C), Number))   # col keys replaced by numbers
    end

    # ── Selectors ───────────────────────────────────────────────────────────────

    @testset "Between – struct construction" begin
        b = Between("aardvark", "zebra")
        @test b.lo == "aardvark"
        @test b.hi == "zebra"
    end

    @testset "Between – .. operator" begin
        b = "aardvark".."zebra"
        @test b isa Between
        @test b.lo == "aardvark"
        @test b.hi == "zebra"
    end

    @testset "Between – getindex inclusive bounds" begin
        A = Assoc(["apple","banana","cherry","date","elderberry"],
                  ["c1","c2","c3","c4","c5"],
                  [1.0, 2.0, 3.0, 4.0, 5.0])
        B = A["banana".."date", :]
        @test sort(collect(getrow(B))) == ["banana","cherry","date"]
        @test nnz(B) == 3
    end

    @testset "Between – getindex single-element range" begin
        A = Assoc(["a","b","c"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A["b".."b", :]
        @test collect(getrow(B)) == ["b"]
        @test nnz(B) == 1
    end

    @testset "Between – getindex empty when lo > hi" begin
        A = Assoc(["a","b","c"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A["z".."a", :]
        @test isempty(B) || nnz(B) == 0
    end

    @testset "EndsWith – struct construction" begin
        e = EndsWith("_score")
        @test e.suffix == "_score"
    end

    @testset "EndsWith – getindex" begin
        A = Assoc(["author_id","author_score","doc_id","doc_score"],
                  ["c1","c2","c3","c4"],
                  [1.0, 2.0, 3.0, 4.0])
        B = A[EndsWith("_score"), :]
        @test sort(collect(getrow(B))) == ["author_score","doc_score"]
        @test nnz(B) == 2
    end

    @testset "EndsWith – no match returns empty" begin
        A = Assoc(["alpha","beta"], ["c1","c2"], [1.0, 2.0])
        B = A[EndsWith("_score"), :]
        @test isempty(B) || nnz(B) == 0
    end

    @testset "Contains – struct construction" begin
        c = Contains("chunk")
        @test c.substr == "chunk"
    end

    @testset "Contains – getindex" begin
        A = Assoc(["chunk:001","chunk:002","doc:001","meta:001"],
                  ["c1","c2","c3","c4"],
                  [1.0, 2.0, 3.0, 4.0])
        B = A[Contains("chunk"), :]
        @test sort(collect(getrow(B))) == ["chunk:001","chunk:002"]
        @test nnz(B) == 2
    end

    @testset "Contains – substring anywhere in key" begin
        A = Assoc(["prefix_abc","abc_suffix","no_match"],
                  ["c1","c2","c3"],
                  [1.0, 2.0, 3.0])
        B = A[Contains("abc"), :]
        @test sort(collect(getrow(B))) == ["abc_suffix","prefix_abc"]
        @test nnz(B) == 2
    end

    @testset "String macro sw\"\" → StartsWith" begin
        sel = sw"ca"
        @test sel isa StartsWith
        @test sel.inputString == "ca"
    end

    @testset "String macro ew\"\" → EndsWith" begin
        sel = ew"_score"
        @test sel isa EndsWith
        @test sel.suffix == "_score"
    end

    @testset "String macro has\"\" → Contains" begin
        sel = has"chunk"
        @test sel isa Contains
        @test sel.substr == "chunk"
    end

    @testset "sw macro via getindex" begin
        A = Assoc(["alice","bob","carol"], ["c1","c2","c3"], [1.0, 2.0, 3.0])
        B = A[sw"ca", :]
        @test collect(getrow(B)) == ["carol"]
    end

    @testset "ew macro via getindex" begin
        A = Assoc(["author_id","author_score","doc_score"],
                  ["c1","c2","c3"],
                  [1.0, 2.0, 3.0])
        B = A[ew"_score", :]
        @test sort(collect(getrow(B))) == ["author_score","doc_score"]
    end

    @testset "has macro via getindex" begin
        A = Assoc(["chunk:001","doc:001","chunk:002"],
                  ["c1","c2","c3"],
                  [1.0, 2.0, 3.0])
        B = A[has"chunk", :]
        @test sort(collect(getrow(B))) == ["chunk:001","chunk:002"]
    end

    @testset "Selectors – column axis (j selector)" begin
        A = Assoc(["r1","r2","r3"],
                  ["score_final","score_interim","label"],
                  [1.0, 2.0, 3.0])
        B = A[:, sw"score"]
        @test sort(collect(getcol(B))) == ["score_final","score_interim"]
        C = A[:, ew"_final"]
        @test collect(getcol(C)) == ["score_final"]
        D = A[:, has"score"]
        @test sort(collect(getcol(D))) == ["score_final","score_interim"]
        E = A[:, "score_final".."score_interim"]
        @test sort(collect(getcol(E))) == ["score_final","score_interim"]
    end

end
