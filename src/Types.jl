mutable struct KEGGReaction

    ec_number::String
    kegg_reaction_number::String
    kegg_enzyme_name::String
    kegg_reaction_markup::String
    kegg_reaction_forward::String
    kegg_reaction_reverse::String

    KEGGReaction() = new()
end

mutable struct KEGGCompound
    
    # data -
    kegg_compound_id::String
    kegg_compound_name::String
    kegg_compound_formula::String
    kegg_compound_mw::Float64

    KEGGCompound() = new()
end

mutable struct KEGGOrganism

    organism_id::String
    organism_code::String
    species_description::String
    species_taxonomy::String

    KEGGOrganism() = new()
end

mutable struct KEGGSequence

    gene_location::String
    type::Symbol
    body::String
    header::String

    KEGGSequence() = new()
end
