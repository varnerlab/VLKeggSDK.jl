mutable struct KEGGReaction

    ec_number::Union{Missing, String, Array{String,1}}
    reaction_number::Union{Missing,String}
    enzyme_name::Union{Missing,String}
    reaction_markup::Union{Missing,String}
    reaction_forward::Union{Missing,String}
    reaction_reverse::Union{Missing,String}
    stoichiometric_dictionary::Union{Missing,Dict{String,Number}}

    KEGGReaction() = new()
end

mutable struct KEGGCompound

    # data -
    compound_id::String
    compound_name::String
    compound_formula::String
    compound_mw::Union{Missing,Float64}
    atom_dictionary::Union{Missing,Dict{String,Number}}

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
