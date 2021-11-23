using VLKeggSDK
using DataFrames
using ProgressMeter
using BSON

# setup list of reactions -
rn_number_array = [

    # upper glycolysis -
    "rn:R00299" # 1
    "rn:R00771" # 2
    "rn:R00756" # 3
    "rn:R00762" # 4
    "rn:R01068" # 5
    "rn:R01015" # 6
    "rn:R01061" # 7
    "rn:R01512" # 8
    "rn:R01518" # 9
    "rn:R00658" # 10
    "rn:R00200" # 11

    # AcCoA formation -
    "rn:R00199" # 12
    "rn:R01699" # 13
    "rn:R02569" # 14
    "rn:R08550" # 15
    "rn:R00235" # 16
    "rn:R00229" # 17

    # TCA cycle -
    "rn:R00351" # 18
    "rn:R01324" # 19
    "rn:R00267" # 20
    "rn:R01700" # 21 
    "rn:R02570" # 22
    "rn:R08550" # 23
    "rn:R00405" # 24
    "rn:R01082" # 25
    "rn:R00342" # 26

    # OxPhos -
    "rn:R02164" # 27
    "rn:R00081" # 28
    "rn:R00004" # 29
]

# download these reactions -
reaction_kegg_metabolite_markup_array = Array{KEGGReaction,1}()
@showprogress "Reactions: " for kegg_reaction_number in rn_number_array

    # get the reaction in KEGG metabolite format -
    kegg_reaction_object = get_reaction_for_rn_number(kegg_reaction_number) |> check
    if (isnothing(kegg_reaction_object) == false)
        push!(reaction_kegg_metabolite_markup_array, kegg_reaction_object)
    end
end

# ok: lets add some reactions by hand -
# ec_number::String
# reaction_number::String
# enzyme_name::String
# reaction_markup::String
# reaction_forward::Union{Missing,String}
# reaction_reverse::Union{Missing,String}
# stoichiometric_dictionary::Union{Missing,Dict{String,Number}}

# complex V
CV = KEGGReaction() # 30
CV.ec_number = "ec:7.1.2.1"
CV.reaction_number = "rn:74aa5235-32e2-403a-9043-5b7e59d56255"
CV.enzyme_name = "proton-translocating ATPase"
CV.reaction_markup = "C00008 + C00009 + 3 C00080 <=> C00002 + C00001 + 3 C00080"
CV.reaction_forward = "C00008 + C00009 + 3 C00080"
CV.reaction_reverse = "C00002 + C00001 + 3 C00080"
CV.stoichiometric_dictionary = Dict("C00008" => -1, "C00009" => -1, "C00002" => 1, "C00001" => 1)
push!(reaction_kegg_metabolite_markup_array, CV)

# complex III
CIII = KEGGReaction() # 31
CIII.ec_number = "ec:7.1.1.8"
CIII.reaction_number = "rn:a484c567-c328-42ea-9c39-3ebac4a587c8"
CIII.enzyme_name = "complex III"
CIII.reaction_markup = "C00530 +  2 C00125 <=> C00472 +  2 C00126 + 2 C00080"
CIII.reaction_forward = "C00530 +  2 C00125"
CIII.reaction_reverse = "C00472 +  2 C00126 + 2 C00080"
CIII.stoichiometric_dictionary = Dict("C00530" => -1, "C00125" => -2, "C00472" => 1, "C00126" => 2, "C00080" => 2)
push!(reaction_kegg_metabolite_markup_array, CIII)

# CI -
CI = KEGGReaction() # 32
CI.ec_number = "ec:7.1.1.2"
CI.reaction_number = "rn:R11945"
CI.enzyme_name = "complex I"
CI.reaction_markup = "C00399 + C00004 + 6 C00080 <=> C00390 + C00003 + 6 C00080"
CI.reaction_forward = "C00399 + C00004 + 6 C00080"
CI.reaction_reverse = "C00390 + C00003 + 6 C00080"
CI.stoichiometric_dictionary = Dict("C00399" => -1, "C00004" => -1, "C00390" => 1, "C00003" => 1)
push!(reaction_kegg_metabolite_markup_array, CI)

# build the metabolites table -
compound_record_array = Array{KEGGCompound,1}()
@showprogress "Metabolites: " for reaction_obj in reaction_kegg_metabolite_markup_array

    # get the reaction number -
    kegg_reaction_markup = reaction_obj.reaction_markup

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
model[:compounds] = unique!((unique_compound_array |> DataFrame))
model[:reactions] = unique!((reaction_kegg_metabolite_markup_array |> DataFrame))

# setup path -
_PATH_TO_MODEL_FILE = "./test/model/model.bson"
bson(_PATH_TO_MODEL_FILE, model)
