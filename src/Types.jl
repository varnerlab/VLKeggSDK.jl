mutable struct KEGGReaction

    ec_number::String
    kegg_reaction_number::String
    kegg_enzyme_name::String
    kegg_reaction_markup::String
    reaction_forward::Union{Missing,String}
    reaction_reverse::Union{Missing,String}

    KEGGReaction() = new()
end

mutable struct VLMetabolicReaction

    VLMetabolicReaction() = new()
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
    sequence::Union{Missing,BioSequences.LongSequence}
    header::String

    KEGGSequence() = new()
end


mutable struct KEGGPathway

    # data -
    pathway_id::String
    pathway_description::String

    KEGGPathway() = new()
end
