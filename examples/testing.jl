# Functions that are useful for testing
using Test, JLD2, D4M, SparseArrays
#include("loadD4M.jl")

UnionArray = Array{Union{AbstractString,Number}}

# Check whether two associative arrays are "equal"
function isequal(A::Assoc,B::Assoc)
    pass = true
    why = ""
    rA,cA,vA = find(A)
    rB,cB,vB = find(B)
    adjA = A.A
    adjB = B.A

    # Check sizes of r,c,v match
    if ~(size(rA,1)==size(rB,1) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Row key sizes don't match:\n\tsize(rA): "*string(size(rA))*"\n\tsize(rB):"*string(size(rB))*"\n"
    end
    if ~(size(cA)==size(cB) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Column key sizes don't match:\n\tsize(cA): "*string(size(cA))*"\n\tsize(cB):"*string(size(cB))*"\n"
    end
    if ~(size(vA)==size(vB) && size(rA,2)==size(rB,2))
        pass = false
        why = why*"Value sizes don't match:\n\tsize(vA): "*string(size(vA))*"\n\tsize(vB):"*string(size(vB))*"\n"
    end

    # Check r,c,v match
    if ~all(rA .== rB)
        pass = false
        why = why*"Row keys don't match\n"
    end
    if ~all(cA .== cB)
        pass = false
        why = why*"Column keys don't match\n"
    end
    if ~all(vA .== vB)
        pass = false
        why = why*"Values don't match\n"
    end

    # Check sparse matrices match
    if ~(adjA == adjB)
        pass = false
        why = why*"Sparse matrices don't match\n"
    end

    if ~pass
        println(why)
    end

    return pass
end

# Type and size testing of Assoc and its components
function testassoc(A)
    pass = true
    why = ""

    # Check is A is correct data type
    if ~isa(A,Assoc)
        pass = false
        why = why*"Assoc wrong type: "*string(typeof(A))*"\n"
    end

    # Check row,col,val are correct data type
    if ~isa(A.row,UnionArray)
        pass = false
        why = why*"Row wrong type: "*string(typeof(A.row))*"\n"
    end
    if ~isa(A.col,UnionArray)
        pass = false
        why = why*"Col wrong type: "*string(typeof(A.col))*"\n"
    end
    if ~isa(A.val,UnionArray)
        pass = false
        why = why*"Val wrong type: "*string(typeof(A.val))*"\n"
    end

    # Check sparse matrix is right data type
    if ~isa(A.A,SparseMatrixCSC)
        pass = false
        why = why*"Sparse matrix wrong type: "*string(typeof(A.A))*"\n"
    end

    # Check size of row and col arrays match dimensions of sparse matrix
    if ~length(A.row) == size(A.A,1)
        pass = false
        why = why*"Row length does not match sparse matrix dimension 1:\n\tlength(A.row): "*string(length(A.row))*"\n\tsize(A.A,1): "*string(size(A.A,1))*"\n"
    end
    if ~length(A.col) == size(A.A,2)
        pass = false
        why = why*"Col length does not match sparse matrix dimension 2:\n\tlength(A.col): "*string(length(A.col))*"\n\tsize(A.A,2): "*string(size(A.A,2))*"\n"
    end

    # Check that numeric values are in sparse matrix, not in A.val
    if ~isempty(A) && ~(!all(isa.(A.val,Number)) || A.val == [1.0])
        pass = false
        why = why*"Numeric values in wrong place"
    end

    if ~pass
        println(why)
    end

    return pass
end

function testassoc(A,B)
    pass = true
    pass = pass && testassoc(A)
    pass = pass && isequal(A,B)
end

# Run Tests
@testset "All Tests" begin
    #include("loadD4M.jl")
    @testset "Intro Tests" begin
        intro_res = load("testing_results/1intro_results.jld")["intro_res"]
        @testset "Assoc Intro" begin
            include("1Intro/1AssocIntro/AI1_SetupTEST.jl")
            @test testassoc(A,intro_res["AI1_setup"])
            include("1Intro/1AssocIntro/AI2_SubsrefTEST.jl")
            @test testassoc(A1r,intro_res["AI2_subsref"]["A1r"])
            #@test testassoc(A2r)
            @test testassoc(A3r,intro_res["AI2_subsref"]["A3r"])
            @test testassoc(A4r,intro_res["AI2_subsref"]["A4r"])
            @test testassoc(A1c,intro_res["AI2_subsref"]["A1c"])
            #@test testassoc(A2c)
            @test testassoc(A3c,intro_res["AI2_subsref"]["A3c"])
            @test testassoc(A4c,intro_res["AI2_subsref"]["A4c"])
            #@test testassoc(A1v)
            include("1Intro/1AssocIntro/AI3_MathTEST.jl")
            @test testassoc(A,intro_res["AI3_math"]["A"])
            @test testassoc(sum(A,1))
            @test testassoc(sum(A,1),intro_res["AI3_math"]["sum1"])
            @test testassoc(sum(A,2),intro_res["AI3_math"]["sum2"])
            @test testassoc(Aab,intro_res["AI3_math"]["Aab"])
            @test testassoc(F,intro_res["AI3_math"]["F"])
            @test testassoc(Fn,intro_res["AI3_math"]["Fn"])
            @test testassoc(AtA,intro_res["AI3_math"]["AtA"])
            include("1Intro/1AssocIntro/AI4_AdvConstructTEST.jl")
            @test testassoc(A00,intro_res["AI4_construct"]["A00"])
            @test testassoc(A01,intro_res["AI4_construct"]["A01"])
            @test testassoc(A02,intro_res["AI4_construct"]["A02"])
            @test testassoc(A03,intro_res["AI4_construct"]["A03"])
            @test testassoc(A04,intro_res["AI4_construct"]["A04"])
            @test testassoc(A05,intro_res["AI4_construct"]["A05"])
            @test testassoc(A06,intro_res["AI4_construct"]["A06"])
            @test testassoc(A11,intro_res["AI4_construct"]["A11"])
            @test testassoc(A12,intro_res["AI4_construct"]["A12"])
            @test testassoc(A13,intro_res["AI4_construct"]["A13"])
            @test testassoc(A14,intro_res["AI4_construct"]["A14"])
            @test testassoc(A15,intro_res["AI4_construct"]["A15"])
            @test testassoc(A16,intro_res["AI4_construct"]["A16"])
        end
        @testset "Edge Art" begin
            include("1Intro/2EdgeArt/EA1_GraphTEST.jl")
            @test testassoc(Ev,intro_res["EA1_graph"]["Ev"])
            @test testassoc(Av,intro_res["EA1_graph"]["Av"])
            @test testassoc(Ae,intro_res["EA1_graph"]["Ae"])
            include("1Intro/2EdgeArt/EA2_SubsrefTEST.jl")
            @test testassoc(Eo,intro_res["EA2_subsref"]["Eo"])
            @test testassoc(Eog,intro_res["EA2_subsref"]["Eog"])
            include("1Intro/2EdgeArt/EA3_SubGraphTEST.jl")
            @test testassoc(Ev)
            @test testassoc(EvO,intro_res["EA3_subgraph"]["EvO"])
            @test testassoc(EvG,intro_res["EA3_subgraph"]["EvG"])
            @test testassoc(AvOG,intro_res["EA3_subgraph"]["AvOG"])
            @test testassoc(AeOG,intro_res["EA3_subgraph"]["AeOG2"])
        end
    end
    @testset "Apps" begin
        @testset "Entity Analysis" begin
            include("2Apps/1EntityAnalysis/EA1_ReadTEST.jl")
            apps_EA1 = load("testing_results/2apps_1EA1.jld")["apps_EA1"]
            @test testassoc(E,apps_EA1["E"])
            include("2Apps/1EntityAnalysis/EA2_StatTEST.jl")
            apps_EA2 = load("testing_results/2apps_1EA2.jld")["apps_EA2"]
            @test testassoc(sum(logical(col2type(E,"/")),1),apps_EA2["Ent"])
            @test testassoc(En,apps_EA2["En"])
            @test testassoc(An,apps_EA2["An"])
            @test full(sum(adj(An[:,StartsWith("LOCATION/,")]),2)) == apps_EA2["plot"]
            include("2Apps/1EntityAnalysis/EA3_FacetTEST.jl")
            apps_EA3 = load("testing_results/2apps_1EA3.jld")["apps_EA3"]
            @test testassoc(F,apps_EA3["F"])
            @test testassoc(Fn,apps_EA3["Fn"])
            @test testassoc(F' > 1,apps_EA3["F2"])
            @test testassoc(Fn' > 0.02,apps_EA3["Fn2"])
            include("2Apps/1EntityAnalysis/EA4_GraphTEST.jl")
            apps_EA4 = load("testing_results/2apps_1EA4.jld")["apps_EA4"]
            @test testassoc(Ae,apps_EA4["Ae"])
            @test testassoc(Ep,apps_EA4["Ep"])
            @test testassoc(Ap,apps_EA4["Ap"])
            @test testassoc(Ad,apps_EA4["Ad"])
            include("2Apps/1EntityAnalysis/EA5_GraphQueryTEST.jl")
            apps_EA5 = load("testing_results/2apps_1EA5.jld")["apps_EA5"]
            @test testassoc(A,apps_EA5["A"])
            @test testassoc(An,apps_EA5["An"])
            @test testassoc((A[p,x] > 4) & (An[p,x] > 0.3),apps_EA5["Amf"])
            @test testassoc(A[p1,p1],apps_EA5["Ap1"])
            @test testassoc(A[p2,p2] > 1,apps_EA5["Ap2"])
        end
        PyPlot.close()
        PyPlot.close()
        PyPlot.close()
        PyPlot.close()
        PyPlot.close()
        PyPlot.close()
        @testset "Track Analysis" begin
            include("2Apps/2TrackAnalysis/findtrackgraph.jl")
            include("2Apps/2TrackAnalysis/findtracks.jl")
            include("2Apps/2TrackAnalysis/TA1_BuildTEST.jl")
            apps_TA1 = load("testing_results/2apps_2TA1.jld")["apps_TA1"]
            @test testassoc(E3,apps_TA1["E3"])
            @test testassoc(Etx,apps_TA1["Etx"])
            @test testassoc(Ext,apps_TA1["Ext"])
            @test testassoc(At,apps_TA1["At"])
            @test testassoc(Ax,apps_TA1["Ax"])
            include("2Apps/2TrackAnalysis/TA2_QueryTEST.jl")
            apps_TA2 = load("testing_results/2apps_2TA2.jld")["apps_TA2"]
            @test testassoc(A,apps_TA2["A"])
            @test testassoc(A[:,p1*p2],apps_TA2["Ap1p2"])
            @test testassoc(A[t,:] == x,apps_TA2["At"])
            include("2Apps/2TrackAnalysis/TA3_GraphTEST.jl")
            apps_TA3 = load("testing_results/2apps_2TA3.jld")["apps_TA3"]
            @test testassoc(A,apps_TA3["A"])
            @test testassoc(G,apps_TA3["G"])
            @test testassoc(G > 5,apps_TA3["G5"])
            @test testassoc(Go,apps_TA3["Go"])
            @test testassoc((Go > 2) & ((Go ./ G) > 0.2),apps_TA3["GoG"])
        end
    end
    PyPlot.close()
    PyPlot.close()
    PyPlot.close()
    @testset "Scaling" begin
        @testset "Parallel Database" begin
        include("3Scaling/2ParallelDatabase/KronGraph500NoPerm.jl")
        println("pDB01_DataTEST.jl")
        include("3Scaling/2ParallelDatabase/pDB01_DataTEST.jl")
        PyPlot.close()
        PyPlot.close()
            println("pDB02_FileTEST.jl")
            include("3Scaling/2ParallelDatabase/pDB02_FileTEST.jl")
            println("pDB03_AssocTEST.jl")
            include("3Scaling/2ParallelDatabase/pDB03_AssocTEST.jl")
            @test testassoc(A)
            @test testassoc(E)
            println("pDB04_DegreeTEST.jl")
            include("3Scaling/2ParallelDatabase/pDB04_DegreeTEST.jl")
            PyPlot.close()
            PyPlot.close()
            @test testassoc(Aall)
            @testset "Using Database" begin
                println("pDB05_DBsetupTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB05_DBsetupTEST.jl")
                println("pDB06_AdjInsertTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB06_AdjInsertTEST.jl")
                println("pDB07_AdjQueryTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB07_AdjQueryTEST.jl")
                PyPlot.close()
                @test testassoc(Adeg)
                @test testassoc(A)
                println("pDB08_AdjQueryItTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB08_AdjQueryItTEST.jl")
                println("pDB09_AdjJoinTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB09_AdjJoinTEST.jl")
                println("pDB10_EdgeInsertTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB10_EdgeInsertTEST.jl")
                println("pDB11_EdgeQueryTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB11_EdgeQueryTEST.jl")
                println("pDB12_EdgeQueryItTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB12_EdgeQueryItTEST.jl")
                println("pDB13_EdgeJoinTEST.jl")
                include("3Scaling/2ParallelDatabase/pDB13_EdgeJoinTEST.jl")
                PyPlot.close()

            end
        end
        
        
        PyPlot.close()
        PyPlot.close()
        PyPlot.close()
        @testset "Matrix Performance" begin
            println("MP1_DenseTEST.jl")
            include("3Scaling/3MatrixPerformance/MP1_DenseTEST.jl")
            println("MP2_SparseTEST.jl")
            include("3Scaling/3MatrixPerformance/MP2_SparseTEST.jl")
            println("MP3_AssocTEST.jl")
            include("3Scaling/3MatrixPerformance/MP3_AssocTEST.jl")
            println("MP4_AssocCatKeyTEST.jl")
            include("3Scaling/3MatrixPerformance/MP4_AssocCatKeyTEST.jl")
            println("MP5_AssocCatValKeyTEST.jl")
            include("3Scaling/3MatrixPerformance/MP5_AssocCatValKeyTEST.jl")
            println("MP6_AssocPlus.jl")
            include("3Scaling/3MatrixPerformance/MP6_AssocPlus.jl")
        end
    end
end