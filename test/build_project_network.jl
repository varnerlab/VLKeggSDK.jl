using VLKeggSDK
using DataFrames
using ProgressMeter

# organism code -
list_of_pathways = [
    "ec00010" # glycolysis
    "ec00020" # TCA cycle
    "ec00030" # pentose phosphate pathway
    "ec00190" # oxidative phosphorylation
    "ec00910" # nitrogen metabolism
    "ec00900" # Terpenoid backbone biosynthesis
    "ec00650" # Butanoate metabolism
]

# we'll get the ec's for these pathways -
ec_number_array = get_ec_numbers_for_pathway(list_of_pathways) |> check

# N = length(ec_number_array)
# reaction_obj_array = Array{KEGGReaction,1}()
# @showprogress for (index, ec_number) in enumerate(ec_number_array)

#     # println("Starting -> $(ec_number) $(index) of $(N)")

#     rxn_object = get_reactions_for_ec_number(ec_number) |> check
#     if (isnothing(rxn_object) == false)
#         append!(reaction_obj_array, rxn_object)
#     end
# end

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

# now that we have the list of ec numbers -> build a reaction table from these ec numbers
# reaction_table = get_reactions_for_ec_number(ec_number_array) |> check |> DataFrame
