# Load D4M Module
include("loadD4M.jl")

# Run Assoc Intro Example
cd("1Intro/1AssocIntro/")
include("AI1_SetupTEST.jl")
include("AI2_SubsrefTEST.jl")
include("AI3_MathTEST.jl")
include("AI4_AdvConstructTEST.jl")

# Run Edge Art Example
cd("../2EdgeArt/")
include("EA1_GraphTEST.jl")
include("EA2_SubsrefTEST.jl")
include("EA3_SubGraphTEST.jl")

# Run Entity Analysis Example
cd("../../2Apps/1EntityAnalysis/")
include("EA1_ReadTEST.jl")
include("EA2_StatTEST.jl")
include("EA3_FacetTEST.jl")
include("EA4_GraphTEST.jl")
include("EA5_GraphQueryTEST.jl")

# Run Parallel Database Example
cd("../../3Scaling/2ParallelDatabase")
include("pDB01_DataTEST.jl")
include("pDB02_FileTEST.jl")
include("pDB03_AssocTEST.jl")
include("pDB04_DegreeTEST.jl")

# Run Matrix Performance Example
cd("../3MatrixPerformance/")
include("MP1_DenseTEST.jl")
include("MP2_SparseTEST.jl")
include("MP3_AssocTEST.jl")
include("MP4_AssocCatKeyTEST.jl")
include("MP5_AssocCatValKeyTEST.jl")
include("MP6_AssocPlus.jl")
