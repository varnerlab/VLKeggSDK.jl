using VLKeggSDK
using DataFrames
using ProgressMeter
using BSON

# organism code -
list_of_pathways = ["ec00010" # glycolysis
    "ec00020" # TCA cycle
    "ec00030" # pentose phosphate pathway
    "ec00190" # oxidative phosphorylation
    "ec00910" # nitrogen metabolism
    "ec00900" # Terpenoid backbone biosynthesis
    "ec00640" # Propanoate metabolism
]

# we'll get the ec's for these pathways -
ec_number_array = get_ec_numbers_for_pathway(list_of_pathways) |> check
N = length(ec_number_array)
reaction_obj_array = Array{KEGGReaction,1}()
@showprogress "Reactions: " for (index, ec_number) in enumerate(ec_number_array)

    rxn_object = get_reactions_for_ec_number(ec_number) |> check
    if (isnothing(rxn_object) == false)
        append!(reaction_obj_array, rxn_object)
    end
end

# list of names that we need to replace -
name_replace_dict = Dict{String,String}()
name_replace_dict["nad+"] = "nad"
name_replace_dict["nadp+"] = "nadp"
name_replace_dict["h+"] = "h"

# we need clean up this a bit before we test with the code generator -
cleaned_reaction_obj_array = Array{KEGGReaction,1}()
for reaction_obj in reaction_obj_array

    # need to check - is either the reaction_forward or reaction_reverse missing?
    if (ismissing(reaction_obj.reaction_forward) == false &&
        ismissing(reaction_obj.reaction_reverse) == false)

        # ok: so if we get here then we forward and reverse strings, but could have issue w/name s
        for (key, value) in name_replace_dict

            # old forward and back -
            original_forward = reaction_obj.reaction_forward
            original_backward = reaction_obj.reaction_reverse

            # update -
            reaction_obj.reaction_forward = replace(original_forward, key => value)
            reaction_obj.reaction_reverse = replace(original_backward, key => value)
        end

        # grab -
        push!(cleaned_reaction_obj_array, reaction_obj)
    end
end

# convert to kegg reaction (metabolites in Cxxxx) -
reaction_kegg_metabolite_markup_array = Array{KEGGReaction,1}()
@showprogress "KEGG reaction format: " for reaction_object in cleaned_reaction_obj_array

    # get the reaction number -
    kegg_reaction_number = reaction_object.kegg_reaction_number

    # get the reaction in KEGG metabolite format -
    kegg_reaction_object = get_reaction_for_rn_number(kegg_reaction_number) |> check
    if (isnothing(reaction_object) == false)
        push!(reaction_kegg_metabolite_markup_array, kegg_reaction_object)
    end
end

# build the metabolites table -
compound_record_array = Array{KEGGCompound,1}()
@showprogress "Metabolites: " for reaction_obj in reaction_kegg_metabolite_markup_array

    # get the reaction number -
    kegg_reaction_markup = reaction_obj.kegg_reaction_markup

    # get the compound symbols -
    tmp_compound_array = extract_metabolite_symbols(kegg_reaction_markup)
    compound_record = get_compound_records(tmp_compound_array) |> check
    if (isnothing(compound_record) == false)
        append!(compound_record_array, compound_record)
    end
end

# for some reason unique is not working - so ...
unique_compound_array = Array{KEGGCompound,1}()
for compound_object in compound_record_array
    if (in(compound_object, unique_compound_array) == false)
        push!(unique_compound_array, compound_object)
    end
end

# Dump model to disk -
model = Dict{Symbol,Any}()
model[:compounds] = (unique_compound_array |> DataFrame)
model[:reactions] = (cleaned_reaction_obj_array |> DataFrame)
model[:kegg_reactions] = (reaction_kegg_metabolite_markup_array |> DataFrame)

# setup path -
_PATH_TO_MODEL_FILE = "./test/model/model.bson"
bson(_PATH_TO_MODEL_FILE, model)
