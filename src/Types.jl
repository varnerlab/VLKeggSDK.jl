mutable struct KEGGReaction

    ec_number::String
    kegg_reaction_number::String
    kegg_enzyme_name::String
    kegg_reaction_markup::String

    KEGGReaction() = new()
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
    body::Array{SubString{String},1}
    header::String

    KEGGSequence() = new()
end
