# Load D4M Module
include("loadD4M.jl")

# Run Assoc Intro Example
include("1Intro/1AssocIntro/AI1_SetupTEST.jl")
include("1Intro/1AssocIntro/AI2_SubsrefTEST.jl")
include("1Intro/1AssocIntro/AI3_MathTEST.jl")
include("1Intro/1AssocIntro/AI4_AdvConstructTEST.jl")

# Run Edge Art Example
include("1Intro/2EdgeArt/EA1_GraphTEST.jl")
include("1Intro/2EdgeArt/EA2_SubsrefTEST.jl")
include("1Intro/2EdgeArt/EA3_SubGraphTEST.jl")

# Run Entity Analysis Example
include("2Apps/1EntityAnalysis/EA1_ReadTEST.jl")
include("2Apps/1EntityAnalysis/EA2_StatTEST.jl")
include("2Apps/1EntityAnalysis/EA3_FacetTEST.jl")
include("2Apps/1EntityAnalysis/EA4_GraphTEST.jl")
include("2Apps/1EntityAnalysis/EA5_GraphQueryTEST.jl")

# Run Parallel Database Example
include("3Scaling/2ParallelDatabase/pDB01_DataTEST.jl")
include("3Scaling/2ParallelDatabase/pDB02_FileTEST.jl")
include("3Scaling/2ParallelDatabase/pDB03_AssocTEST.jl")
include("3Scaling/2ParallelDatabase/pDB04_DegreeTEST.jl")

# Run Matrix Performance Example
include("3Scaling/3MatrixPerformance/MP1_DenseTEST.jl")
include("3Scaling/3MatrixPerformance/MP2_SparseTEST.jl")
include("3Scaling/3MatrixPerformance/MP3_AssocTEST.jl")
include("3Scaling/3MatrixPerformance/MP4_AssocCatKeyTEST.jl")
include("3Scaling/3MatrixPerformance/MP5_AssocCatValKeyTEST.jl")
include("3Scaling/3MatrixPerformance/MP6_AssocPlus.jl")
