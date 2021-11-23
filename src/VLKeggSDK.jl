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
export get_ec_numbers_for_pathway
export get_genes_in_organism_pathway
export get_pathways_for_organism
export get_kegg_organism_codes
export get_sequence_for_gene
export get_sequence_for_protein
export get_compound_records
export get_compound_records_for_reaction
export get_reactions_for_ec_number
export get_reaction_for_rn_number
export build_metabolite_keggid_matching_table

export check
export extract_db_file_section
export extract_metabolite_symbols
export extract_stoichiometric_dictionary
export extract_atom_dictionary

export http_get_call_with_url

end # module
