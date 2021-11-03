# setup project paths -
const _PATH_TO_SRC = dirname(pathof(@__MODULE__))

# load external packages -
using Test
using HTTP

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Base.jl"))
include(joinpath(_PATH_TO_SRC, "Network.jl"))
include(joinpath(_PATH_TO_SRC, "Reactions.jl"))

# URL string -
const _KEGG_LINKAGE_REACTION_URL = "http://rest.kegg.jp/link/rn"
const _KEGG_LINKAGE_EC_URL = "http://rest.kegg.jp/link/ec"
const _KEGG_LIST_URL = "http://rest.kegg.jp/list"