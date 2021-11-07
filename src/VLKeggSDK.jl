module VLKeggSDK

# include -
include("Include.jl")

# type exports -
export KEGGReaction
export KEGGOrgansim
export KEGGSequence
export KEGGCompound
export KEGGPathway

# method exports -
export get_ec_number_for_gene
export get_genes_in_organism_pathway
export get_pathways_for_organism
export get_kegg_organism_codes
export get_sequence_for_gene
export get_sequence_for_protein
export get_compound_records
export get_reactions_for_ec_number
export build_metabolite_keggid_matching_table
export check

end # module
