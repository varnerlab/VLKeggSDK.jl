module VLKeggSDK

# include -
include("Include.jl")

# type exports -
export KEGGReaction
export KEGGOrgansim
export KEGGSequence
export KEGGCompound

# method exports -
export get_compound_records
export get_reactions_for_ec_number
export build_metabolite_keggid_matching_table
export check

end # module
