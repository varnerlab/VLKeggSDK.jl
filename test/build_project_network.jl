using VLKeggSDK
using DataFrames

# organism code -
list_of_pathways = [

    "ec00010"   ; # glycolysis
    "ec00020"   ; # TCA cycle
    "ec00030"   ; # pentose phosphate pathway
    "ec00190"   ; # oxidative phosphorylation
    "ec00910"   ; # nitrogen metabolism
    "ec00900"   ; # Terpenoid backbone biosynthesis
    "ec00650"   ; # Butanoate metabolism
]

# we'll get the ec's for these pathways -
ec_number_array = get_ec_numbers_for_pathway(list_of_pathways) |> check

N = length(ec_number_array)
reaction_obj_array = Array{KEGGReaction,1}()
for (index,ec_number) in enumerate(ec_number_array)

    println("Starting -> $(ec_number) $(index) of $(N)")

    rxn_object = get_reactions_for_ec_number(ec_number) |> check
    if (isnothing(rxn_object) == false)
        append!(reaction_obj_array, rxn_object)
    end

end

# now that we have the list of ec numbers -> build a reaction table from these ec numbers
# reaction_table = get_reactions_for_ec_number(ec_number_array) |> check |> DataFrame
